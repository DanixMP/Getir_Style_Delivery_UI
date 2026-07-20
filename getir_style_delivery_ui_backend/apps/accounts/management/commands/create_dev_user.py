"""Create a local developer-role account for debug tools."""
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

User = get_user_model()

DEV_PHONE = '09120000000'
DEV_PASSWORD = 'dev123456'


class Command(BaseCommand):
    help = 'Create local developer user 09120000000 / dev123456 (developer role).'

    def handle(self, *args, **options):
        user, created = User.objects.get_or_create(
            phone=DEV_PHONE,
            defaults={
                'full_name': 'Dev User',
                'role': 'developer',
                'is_staff': True,
                'is_superuser': True,
            },
        )
        user.set_password(DEV_PASSWORD)
        user.role = 'developer'
        user.is_staff = True
        user.is_superuser = True
        user.full_name = 'Dev User'
        user.save()
        verb = 'Created' if created else 'Updated'
        self.stdout.write(self.style.SUCCESS(
            f'{verb} dev user phone={DEV_PHONE} password={DEV_PASSWORD}'
        ))
