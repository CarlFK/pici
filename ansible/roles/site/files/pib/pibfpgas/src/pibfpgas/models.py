# roles/site/files/pib/pibfpgas/src/pibfpgas/models.py

from django.db import models

BOARD_TYPES = [
    ('arty_a7', 'Arty A7'),
    ('netv2', 'NeTV2'),
    ('ulx3s', 'ULX3S'),
    ('fomu', 'Fomu'),
    ('tt_asic', 'Tiny Tapeout ASIC'),
    ('tt_fpga', 'Tiny Tapeout FPGA Emulation'),
]

class Pi(models.Model):
    port = models.IntegerField()
    mac = models.CharField(max_length=17, blank=True)
    serial_no = models.CharField(max_length=8, blank=True)
    location = models.CharField(max_length=30, blank=True)
    model = models.CharField(max_length=30, blank=True)
    cable_color = models.CharField(max_length=10, blank=True)
    board_type = models.CharField(max_length=20, choices=BOARD_TYPES, default='arty_a7', blank=True)
