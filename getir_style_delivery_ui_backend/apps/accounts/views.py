from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework import status, viewsets
from rest_framework.generics import RetrieveAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import PeykProfile
from .permissions import IsAdmin, IsOperator, IsPeyk
from .otp_serializers import OtpRequestSerializer, OtpVerifySerializer
from .otp_service import request_otp, verify_otp
from .serializers import (
    AdminUserSerializer,
    PhoneTokenObtainPairSerializer,
    PublicPeykSerializer,
    RegisterSerializer,
    UserSerializer,
)

User = get_user_model()


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(
            UserSerializer(user, context={'request': request}).data,
            status=status.HTTP_201_CREATED,
        )


class LoginView(TokenObtainPairView):
    permission_classes = [AllowAny]
    serializer_class = PhoneTokenObtainPairSerializer


class OtpRequestView(APIView):
    """Request a 6-digit OTP. Code is printed to the Django runserver console."""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OtpRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            otp = request_otp(serializer.validated_data['phone'])
        except ValueError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        payload = {'detail': 'OTP sent. Check the Django server console.'}
        if settings.DEBUG or getattr(settings, 'OTP_RETURN_DEBUG_CODE', False):
            payload['debug_code'] = otp.code
        return Response(payload)


class OtpVerifyView(APIView):
    """Verify OTP and return JWT tokens."""
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OtpVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            user = verify_otp(
                serializer.validated_data['phone'],
                serializer.validated_data['code'],
            )
        except ValueError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_400_BAD_REQUEST)

        refresh = RefreshToken.for_user(user)
        refresh['role'] = user.role
        refresh['full_name'] = user.full_name
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user, context={'request': request}).data,
        })


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh = request.data.get('refresh')
        if not refresh:
            return Response({'detail': 'refresh token required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            token = RefreshToken(refresh)
            token.blacklist()
        except TokenError:
            return Response({'detail': 'Invalid or expired token.'},
                            status=status.HTTP_400_BAD_REQUEST)
        return Response(status=status.HTTP_205_RESET_CONTENT)


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user, context={'request': request}).data)

    def patch(self, request):
        serializer = UserSerializer(
            request.user,
            data=request.data,
            partial=True,
            context={'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class PublicPeykView(RetrieveAPIView):
    """Customer-facing Peyk profile by PeykProfile id."""
    permission_classes = [IsAuthenticated]
    serializer_class = PublicPeykSerializer
    queryset = PeykProfile.objects.select_related('user').all()
    lookup_field = 'id'


class AdminUserViewSet(viewsets.ModelViewSet):
    """Operator/admin user management (create vendor/operator, update users)."""
    permission_classes = [IsOperator]
    serializer_class = AdminUserSerializer
    queryset = User.objects.all().order_by('-date_joined')

    def get_permissions(self):
        # Creating/altering admin-level users requires IsAdmin.
        if self.action in ('create', 'partial_update', 'update', 'destroy'):
            return [IsAdmin()]
        return [IsOperator()]

    def get_queryset(self):
        qs = super().get_queryset()
        role = self.request.query_params.get('role')
        if role:
            qs = qs.filter(role=role)
        return qs


class PeykSelfAvailabilityView(APIView):
    """A peyk toggles their own availability (go online / offline)."""
    permission_classes = [IsPeyk]

    def patch(self, request):
        profile = getattr(request.user, 'peyk_profile', None)
        if profile is None:
            return Response({'detail': 'No peyk profile.'},
                            status=status.HTTP_400_BAD_REQUEST)
        is_available = request.data.get('is_available')
        if is_available is None:
            return Response({'detail': 'is_available is required.'},
                            status=status.HTTP_400_BAD_REQUEST)
        profile.is_available = bool(is_available)
        profile.save(update_fields=['is_available', 'updated_at'])
        return Response({'is_available': profile.is_available})
