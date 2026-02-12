from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "EKS FastAPI" in response.text


def test_api_root():
    response = client.get("/api")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello from EKS FastAPI"}


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
