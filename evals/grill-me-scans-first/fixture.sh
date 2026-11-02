#!/usr/bin/env bash
# Scaffold: a small app whose auth and database choices are answerable from the code.
set -euo pipefail
mkdir -p app
cat > requirements.txt <<'T'
fastapi==0.110.0
sqlalchemy==2.0.25
psycopg2-binary==2.9.9
pyjwt==2.8.0
T
cat > README.md <<'T'
# Tasks API
FastAPI service. Postgres via SQLAlchemy. Auth: JWT bearer tokens (see app/auth.py).
T
cat > app/auth.py <<'T'
import jwt

import os

SECRET_ENV = "JWT_SECRET"


def _secret() -> str:
    return os.environ[SECRET_ENV]


def current_user(token: str) -> dict:
    return jwt.decode(token, key=_secret(), algorithms=["HS256"])
T
cat > app/models.py <<'T'
from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)


class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True)
    owner_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String)
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
