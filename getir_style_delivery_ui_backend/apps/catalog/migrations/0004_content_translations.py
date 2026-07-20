from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('catalog', '0003_diningtable_venuepanorama_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='category',
            name='name_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='diningtable',
            name='label_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='homebanner',
            name='subtitle_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='homebanner',
            name='title_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='homefeatureditem',
            name='badge_text_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='item',
            name='description_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='item',
            name='name_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='vendorgallery',
            name='caption_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='venuepanorama',
            name='title_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
    ]
