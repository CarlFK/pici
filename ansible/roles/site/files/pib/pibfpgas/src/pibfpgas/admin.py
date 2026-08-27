from django.contrib import admin
from .models import Pi

class PiAdmin(admin.ModelAdmin):
    list_display = ('port', 'board_type', 'location', 'model', 'cable_color')
    list_filter = ('board_type',)

admin.site.register(Pi, PiAdmin)
