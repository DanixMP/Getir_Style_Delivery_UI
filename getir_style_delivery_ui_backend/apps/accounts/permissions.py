"""
Role-based DRF permissions. Import and reuse these in every app — never
rely on DRF defaults beyond IsAuthenticated.
"""
from rest_framework.permissions import BasePermission


class _RolePermission(BasePermission):
    allowed_roles: tuple = ()

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user and user.is_authenticated and user.role in self.allowed_roles
        )


class IsCustomer(_RolePermission):
    allowed_roles = ('customer',)


class IsPeyk(_RolePermission):
    allowed_roles = ('peyk',)


class IsVendor(_RolePermission):
    allowed_roles = ('vendor',)


class IsOperator(_RolePermission):
    allowed_roles = ('operator', 'admin', 'developer')


class IsAdmin(_RolePermission):
    allowed_roles = ('admin', 'developer')


class IsDeveloper(_RolePermission):
    allowed_roles = ('developer',)
