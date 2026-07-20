"""
Create the bootstrap developer user from env vars DEVELOPER_PHONE and
DEVELOPER_PASSWORD. Run once after the first migration.
"""
from decouple import config as env
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError

User = get_user_model()


class Command(BaseCommand):
    help = 'Create the developer user from DEVELOPER_PHONE / DEVELOPER_PASSWORD env vars.'

    def handle(self, *args, **options):
        phone = env('DEVELOPER_PHONE', default='')
        password = env('DEVELOPER_PASSWORD', default='')
        if not phone or not password:
            raise CommandError('DEVELOPER_PHONE and DEVELOPER_PASSWORD must be set.')

        user, created = User.objects.get_or_create(
            phone=phone,
            defaults={
                'full_name': 'Developer',
                'role': 'developer',
                'is_staff': True,
                'is_superuser': True,
            },
        )
        if not created:
            self.stdout.write(self.style.WARNING(f'Developer user {phone} already exists.'))
            return
        user.set_password(password)
        user.save()
        self.stdout.write(self.style.SUCCESS(f'Created developer user {phone}.'))
