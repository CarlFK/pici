from django.contrib import admin
from .models import *

class PiAdmin(admin.ModelAdmin):
    pass

admin.site.register(Pi, PiAdmin)
