"""Auth endpoints — mounted at /api/v1/auth/."""
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import LoginView, LogoutView, OtpRequestView, OtpVerifyView, RegisterView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='auth-register'),
    path('login/', LoginView.as_view(), name='auth-login'),
    path('otp/request/', OtpRequestView.as_view(), name='auth-otp-request'),
    path('otp/verify/', OtpVerifyView.as_view(), name='auth-otp-verify'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('logout/', LogoutView.as_view(), name='auth-logout'),
]
