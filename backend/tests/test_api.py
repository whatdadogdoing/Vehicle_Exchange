import pytest
import json
import sys
import os

# Add the backend directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

from app import app, db, User, Item
from werkzeug.security import generate_password_hash

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
            yield client
            db.drop_all()

@pytest.fixture
def auth_headers(client):
    user = User(
        username='testuser',
        email='test@example.com',
        password_hash=generate_password_hash('password123'),
        phone='1234567890',
        address='Test Address'
    )
    db.session.add(user)
    db.session.commit()
    
    response = client.post('/api/login', 
        data=json.dumps({
            'email': 'test@example.com',
            'password': 'password123'
        }),
        content_type='application/json'
    )
    
    token = json.loads(response.data)['access_token']
    return {'Authorization': f'Bearer {token}'}

class TestAuthentication:
    def test_register_success(self, client):
        response = client.post('/api/register',
            data=json.dumps({
                'username': 'newuser',
                'email': 'new@example.com',
                'password': 'password123',
                'phone': '1234567890',
                'address': 'New Address'
            }),
            content_type='application/json'
        )
        
        assert response.status_code == 201
        data = json.loads(response.data)
        assert 'access_token' in data
    
    def test_login_success(self, client, auth_headers):
        response = client.post('/api/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'password123'
            }),
            content_type='application/json'
        )
        
        assert response.status_code == 200
        data = json.loads(response.data)
        assert 'access_token' in data

class TestItems:
    def test_get_items(self, client):
        response = client.get('/api/items')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert 'items' in data
    
    def test_create_item_success(self, client, auth_headers):
        response = client.post('/api/items',
            data={
                'name': 'Test Car',
                'description': 'A test car for lending',
                'category': 'car',
                'transaction_type': 'lend',
                'price_per_hour': '10.0'
            },
            headers=auth_headers
        )
        
        assert response.status_code == 201