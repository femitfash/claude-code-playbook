#!/usr/bin/env bash
# Scaffold: a multi-tenant invoicing API whose auth and tenancy model are answerable from the code.
set -euo pipefail
mkdir -p app
cat > requirements.txt <<'T'
fastapi==0.110.0
sqlalchemy==2.0.25
psycopg2-binary==2.9.9
pyjwt==2.8.0
T
cat > README.md <<'T'
# Invoicing API
FastAPI + Postgres (SQLAlchemy). JWT bearer auth; every token carries a tenant_id claim (app/auth.py).
T
cat > app/auth.py <<'T'
import os

import jwt


def current_user(token: str) -> dict:
    claims = jwt.decode(token, key=os.environ["JWT_SECRET"], algorithms=["HS256"])
    return {"user_id": claims["sub"], "tenant_id": claims["tenant_id"], "role": claims.get("role", "member")}
T
cat > app/models.py <<'T'
from sqlalchemy import Column, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class Invoice(Base):
    __tablename__ = "invoices"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, nullable=False, index=True)
    customer = Column(String)
    amount = Column(Numeric)
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
