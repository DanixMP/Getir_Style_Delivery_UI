from django.urls import path

from .views import (
    KillSwitchActivateView,
    KillSwitchDeactivateView,
    KillSwitchStatusView,
)

urlpatterns = [
    path('kill-switch/activate/', KillSwitchActivateView.as_view(), name='kill-switch-activate'),
    path('kill-switch/deactivate/', KillSwitchDeactivateView.as_view(), name='kill-switch-deactivate'),
    path('kill-switch/status/', KillSwitchStatusView.as_view(), name='kill-switch-status'),
]
