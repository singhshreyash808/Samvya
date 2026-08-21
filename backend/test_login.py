import json
import requests
import uuid

url = "http://localhost:8000/auth/login"

payload = {
    "mobile": "9999999999", # some number
    "password": "Password123!",
    "device": {
        "device_uuid": str(uuid.uuid4()),
        "device_name": "Test Device",
        "brand": "Test",
        "model": "Test",
        "android_version": "14",
        "app_version": "1.0.0",
        "fcm_token": ""
    }
}

try:
    res = requests.post(url, json=payload)
    print("Status Code:", res.status_code)
    print("Response:", res.json())
except Exception as e:
    print("Error:", e)
