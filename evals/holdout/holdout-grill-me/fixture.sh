#!/usr/bin/env bash
set -euo pipefail
mkdir -p config billing
cat > requirements.txt <<'T'
django==5.0.2
celery==5.3.6
redis==5.0.1
T
cat > README.md <<'T'
# Billing
Django app. Background jobs run on Celery with a Redis broker (config/settings.py).
T
cat > config/settings.py <<'T'
INSTALLED_APPS = ["billing"]
CELERY_BROKER_URL = "redis://localhost:6379/0"
T
cat > billing/models.py <<'T'
from django.db import models


class Invoice(models.Model):
    customer_email = models.EmailField()
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, default="open")
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
