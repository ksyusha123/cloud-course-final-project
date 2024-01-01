import os

DOCUMENT_API_ENDPOINT = os.environ.get("DOCUMENT_API_ENDPOINT")
REGION = os.environ.get("REGION", 'ru-central1')
ACCESS_KEY_ID = os.environ.get("ACCESS_KEY_ID")
SECRET_ACCESS_KEY = os.environ.get("SECRET_ACCESS_KEY")
VERSION = os.environ.get("VERSION", "1")