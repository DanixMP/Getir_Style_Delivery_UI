from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.test import TestCase, override_settings

User = get_user_model()


class CreateDeveloperUserTests(TestCase):
    @override_settings()
    def test_creates_developer(self):
        import os
        os.environ['DEVELOPER_PHONE'] = '09129999999'
        os.environ['DEVELOPER_PASSWORD'] = 'devpass123'
        try:
            call_command('create_developer_user')
        finally:
            del os.environ['DEVELOPER_PHONE']
            del os.environ['DEVELOPER_PASSWORD']
        user = User.objects.get(phone='09129999999')
        self.assertEqual(user.role, 'developer')
        self.assertTrue(user.is_superuser)
        self.assertTrue(user.check_password('devpass123'))


class CategoriesFixtureTests(TestCase):
    def test_fixture_loads(self):
        from apps.catalog.models import Category
        call_command('loaddata', 'categories')
        self.assertTrue(Category.objects.filter(slug='getir_style_delivery_ui-taxi', is_coming_soon=True).exists())
        self.assertEqual(Category.objects.count(), 6)
