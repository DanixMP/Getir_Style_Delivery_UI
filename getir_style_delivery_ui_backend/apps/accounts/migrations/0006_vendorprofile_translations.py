from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0005_vendorprofile_cover_image_url'),
    ]

    operations = [
        migrations.AddField(
            model_name='vendorprofile',
            name='address_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='vendorprofile',
            name='business_name_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='vendorprofile',
            name='description_translations',
            field=models.JSONField(blank=True, default=dict),
        ),
    ]
