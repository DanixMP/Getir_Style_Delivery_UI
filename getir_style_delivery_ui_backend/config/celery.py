"""Celery application + Beat schedule for GetirStyleDeliveryUi."""
import os

from celery import Celery
from celery.schedules import crontab

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

app = Celery('getir_style_delivery_ui')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

app.conf.beat_schedule = {
    'daily-reports': {
        'task': 'apps.reports.tasks.generate_daily_reports',
        'schedule': crontab(hour=0, minute=5),
    },
    'weekly-reports': {
        'task': 'apps.reports.tasks.generate_weekly_reports',
        'schedule': crontab(hour=0, minute=10, day_of_week=1),
    },
    'monthly-reports': {
        'task': 'apps.reports.tasks.generate_monthly_reports',
        'schedule': crontab(hour=0, minute=15, day_of_month=1),
    },
    'yearly-reports': {
        'task': 'apps.reports.tasks.generate_yearly_reports',
        'schedule': crontab(hour=0, minute=20, month_of_year=1, day_of_month=1),
    },
}


@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
