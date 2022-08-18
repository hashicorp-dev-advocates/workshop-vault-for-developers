"""Flask configuration."""

SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:postgres-admin-password@localhost/payments'
SQLALCHEMY_TRACK_MODIFICATIONS = False