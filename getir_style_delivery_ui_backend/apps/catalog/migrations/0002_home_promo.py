import uuid

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('catalog', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='HomeBanner',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('title', models.CharField(max_length=120)),
                ('subtitle', models.CharField(blank=True, max_length=200)),
                ('image', models.ImageField(blank=True, upload_to='home_banners/')),
                ('image_url', models.CharField(blank=True, help_text='Optional external image URL when no upload is set.', max_length=500)),
                ('city', models.CharField(blank=True, help_text='Leave blank to show in all cities.', max_length=100)),
                ('category_slug', models.SlugField(blank=True, help_text='Optional category to open when the banner is tapped.', max_length=100)),
                ('display_order', models.PositiveSmallIntegerField(default=0)),
                ('is_active', models.BooleanField(default=True)),
                ('starts_at', models.DateTimeField(blank=True, null=True)),
                ('ends_at', models.DateTimeField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
            options={
                'ordering': ['display_order', '-created_at'],
            },
        ),
        migrations.CreateModel(
            name='HomeFeaturedItem',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('section', models.CharField(choices=[('discounted', 'Discounted'), ('today_special', "Today's special")], max_length=20)),
                ('sale_price', models.BigIntegerField(blank=True, help_text='Promo price in Tomans (required for discounted items).', null=True)),
                ('badge_text', models.CharField(blank=True, max_length=40)),
                ('city', models.CharField(blank=True, max_length=100)),
                ('display_order', models.PositiveSmallIntegerField(default=0)),
                ('is_active', models.BooleanField(default=True)),
                ('special_date', models.DateField(blank=True, help_text="For today's specials: show only on this date (blank = every day).", null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('item', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='home_features', to='catalog.item')),
            ],
            options={
                'ordering': ['display_order', '-created_at'],
                'indexes': [models.Index(fields=['section', 'is_active'], name='catalog_hom_section_0f3e2d_idx')],
            },
        ),
    ]
