# pib/pistat/urls.py

# from django.conf import settings
# from django.conf.urls.static import static
from django.urls import re_path

from pistat.views import status

urlpatterns = [
    re_path('stat/(?P<pi_name>\w+)/(?P<status>\w+)', status),
]
# + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT, show_indexes=True)

