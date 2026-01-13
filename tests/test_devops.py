import os
import requests


BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")

API_KEY = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
JWT_SECRET = "supersecret"


def get_token() -> str:
    r = requests.get(f"{BASE_URL}/token", timeout=10)
    r.raise_for_status()
    return r.text.strip().strip('"')


def test_post_devops_ok():
    token = get_token()
    payload = {"message": "hello", "to": "Juan", "from": "Javi", "timeToLifeSec": 60}
    r = requests.post(
        f"{BASE_URL}/DevOps",
        json=payload,
        headers={"X-Parse-REST-API-Key": API_KEY, "X-JWT-KWY": token},
        timeout=10,
    )
    assert r.status_code == 200
    assert "Hello Juan your message will be send" in r.text


def test_post_devops_bad_api_key():
    token = get_token()
    payload = {"message": "hello", "to": "Juan", "from": "Javi", "timeToLifeSec": 60}
    r = requests.post(
        f"{BASE_URL}/DevOps",
        json=payload,
        headers={"X-Parse-REST-API-Key": "bad", "X-JWT-KWY": token},
        timeout=10,
    )
    assert r.status_code in (401, 403)


def test_post_devops_bad_jwt():
    payload = {"message": "hello", "to": "Juan", "from": "Javi", "timeToLifeSec": 60}
    r = requests.post(
        f"{BASE_URL}/DevOps",
        json=payload,
        headers={"X-Parse-REST-API-Key": API_KEY, "X-JWT-KWY": "bad.jwt.token"},
        timeout=10,
    )
    assert r.status_code in (401, 403)


def test_other_methods_return_error():
    r = requests.get(f"{BASE_URL}/DevOps", timeout=10)
    assert "ERROR" in r.text
