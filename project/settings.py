"""
Django settings for the project.

Generated by 'django-admin startproject' using Django 4.2.13.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/4.2/ref/settings/
"""

from pathlib import Path

import dj_database_url
from decouple import Csv, config
from django.utils.log import DEFAULT_LOGGING


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config("SECRET_KEY")

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = config("DEBUG", cast=bool, default=False)

# Hostname
ALLOWED_HOSTS = config("ALLOWED_HOSTS", cast=Csv())
CSRF_TRUSTED_ORIGINS = config("CSRF_TRUSTED_ORIGINS", cast=Csv())


# Application definition

INSTALLED_APPS = [
    # Django apps:
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Third-party apps:
    "django_extensions",
    # Project apps:
    "dataset",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]
if DEBUG and config("DEBUG_SQL", cast=bool, default=False):
    MIDDLEWARE.append("utils.sqlprint.SqlPrintingMiddleware")  # TODO: may use https://pypi.org/project/sqlformatter/

ADMINS = config("ADMINS", cast=Csv(), default="")
if ADMINS:
    ADMINS = [tuple([item.strip() for item in name_email.split("|")]) for name_email in ADMINS]

ROOT_URLCONF = "project.urls"
APPEND_SLASH = True

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "project.wsgi.application"


# Database
# https://docs.djangoproject.com/en/4.2/ref/settings/#databases

DATABASE_URL = config("DATABASE_URL")
DATABASES = {
    "default": dj_database_url.config(),
}
DATABASES["default"]["CONN_MAX_AGE"] = config("DATABASE_CONN_MAX_AGE", default=3600, cast=int)  # seconds


# Password validation
# https://docs.djangoproject.com/en/4.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]


# Internationalization
# https://docs.djangoproject.com/en/4.2/topics/i18n/

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.2/howto/static-files/

STATIC_URL = "/static/"
STATIC_ROOT = str(BASE_DIR / "collected-static")
STATICFILES_DIRS = [str(BASE_DIR / "static")]

# Storage
STORAGES = {
    "default": {
        "BACKEND": config("DEFAULT_FILE_STORAGE", default="django.core.files.storage.FileSystemStorage"),
    },
    "staticfiles": {
        "BACKEND": config("STATICFILES_STORAGE", default="django.contrib.staticfiles.storage.StaticFilesStorage"),
    },
}
DATA_DIR = config("DATA_DIR", cast=Path)

# Default primary key field type
# https://docs.djangoproject.com/en/4.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = "django.db.models.AutoField"


# Logging
LOGGING = DEFAULT_LOGGING.copy()
LOGGING["handlers"]["null"] = {"class": "logging.NullHandler"}
LOGGING["loggers"]["django.security.DisallowedHost"] = {"handlers": ["null"], "propagate": False}
SHELL_PLUS_PRINT_SQL_TRUNCATE = config("SHELL_PLUS_PRINT_SQL_TRUNCATE", cast=int, default=999_999)
