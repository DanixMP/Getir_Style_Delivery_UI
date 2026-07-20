from django.urls import path

from .views import OperatorSummaryView, VendorReportView

urlpatterns = [
    path('vendor/', VendorReportView.as_view(), name='reports-vendor'),
    path('operator/summary/', OperatorSummaryView.as_view(), name='reports-operator-summary'),
]
