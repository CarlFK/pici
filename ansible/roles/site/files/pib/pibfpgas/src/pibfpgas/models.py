# roles/site/files/pib/pibfpgas/src/pibfpgas/models.py

from django.db import models

class Pi(models.Model):
    port = models.IntegerField()
    mac = models.CharField(max_length=17, blank=True)
    serial_no = models.CharField(max_length=8, blank=True)
    location = models.CharField(max_length=30, blank=True)
    model = models.CharField(max_length=30, blank=True)
    cable_color = models.CharField(max_length=10, blank=True)
