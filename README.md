# Item Exchange Platform

A full-stack web application for sharing, lending, and exchanging items between users with real-time communication and enterprise-grade DevOps pipeline.

## 🚀 Features

### Core Functionality
- **Item Management**: List items for lending, giving away, or exchanging
- **User Authentication**: JWT-based auth with email verification
- **Real-time Messaging**: Chat system with file sharing and location sharing
- **Appointment Scheduling**: Schedule meetups with calendar integration
- **Rating System**: User reviews and ratings after transactions
- **Search & Filter**: Advanced filtering by category, type, and location

### Communication
- Real-time messaging between users
- File and image sharing in conversations
- Location sharing for meetups
- Appointment scheduling within chats
- Message editing and deletion

### Transaction Management
- Request system for borrowing/exchanging items
- Accept/reject/edit transaction requests
- Quantity management for lending items
- Transaction history and status tracking

## 🛠️ Tech Stack

### Backend
- **Flask** - Python web framework
- **PostgreSQL** - Primary database
- **SQLAlchemy** - ORM
- **JWT** - Authentication
- **AWS S3** - Image storage
- **AWS SES** - Email notifications
- **Sentry** - Error tracking

### Frontend
- **React** - UI framework
- **React Router** - Navigation
- **Axios** - HTTP client
- **Responsive Design** - Mobile-friendly interface

### DevOps & Infrastructure
- **Docker** - Containerization
- **GitHub Actions** - CI/CD pipeline
- **Terraform** - Infrastructure as Code
- **Kubernetes** - Container orchestration
- **Prometheus & Grafana** - Monitoring
- **AWS ECS** - Container deployment

## 📋 Prerequisites

- Node.js 16+
- Python 3.8+
- PostgreSQL 13+
- Docker & Docker Compose
- AWS Account (optional, for S3/SES)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/item-exchange-platform.git
cd item-exchange-platform
```

### 2. Environment Setup
```bash
# Backend environment
cd backend
cp .env.example .env
# Edit .env with your configuration

# Frontend environment
cd ../frontend
cp .env.example .env
# Edit .env with your API URL
```

### 3. Docker Development
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f
```

### 4. Manual Setup (Alternative)

#### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Database setup
createdb item_exchange
python app.py  # Creates tables automatically
```

#### Frontend Setup
```bash
cd frontend
npm install
npm start
```

## 🔧 Configuration

### Backend Environment Variables (.env)
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/item_exchange
JWT_SECRET_KEY=your-secret-key-here
UPLOAD_FOLDER=uploads
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
S3_BUCKET_NAME=your-s3-bucket
SENTRY_DSN=your-sentry-dsn
```

### Frontend Environment Variables (.env)
```env
REACT_APP_API_URL=http://localhost:5000
```

## 📚 API Documentation

### Authentication
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/forgot-password` - Password reset

### Items
- `GET /api/items` - List all items
- `POST /api/items` - Create new item
- `GET /api/items/:id` - Get item details
- `PUT /api/items/:id` - Update item

### Messaging
- `GET /api/conversations` - Get user conversations
- `POST /api/conversations` - Create conversation
- `GET /api/conversations/:id/messages` - Get messages
- `POST /api/conversations/:id/messages` - Send message

### Transactions
- `POST /api/items/:id/request` - Request item
- `GET /api/requests` - Get user requests
- `POST /api/requests/:id/respond` - Accept/reject request

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │    │   Flask API     │    │   PostgreSQL    │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWS S3        │    │   AWS SES       │    │   Redis Cache   │
│   (Images)      │    │   (Emails)      │    │   (Sessions)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Deployment

### Docker Production
```bash
# Build and deploy
docker-compose -f docker-compose.prod.yml up -d
```

### AWS ECS Deployment
```bash
# Deploy infrastructure
cd terraform
terraform init
terraform apply

# Deploy application
aws ecs update-service --cluster item-exchange --service item-exchange-service --force-new-deployment
```

### CI/CD Pipeline
The project includes automated GitHub Actions workflows:
- **Security scanning** with Trivy and OWASP
- **Automated testing** (unit, integration, E2E)
- **Multi-environment deployment** (staging, production)
- **Canary releases** with automatic rollback
- **Performance monitoring** and alerting

## 📊 Monitoring

### Metrics Dashboard
- Application performance metrics
- Database connection monitoring
- Error rate tracking
- User activity analytics

### Alerts
- High error rates (>5%)
- Slow response times (>2s)
- Database connection issues
- Infrastructure resource usage

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test

# E2E tests
npm run test:e2e

# Load testing
artillery run tests/load/api-load-test.yml
```

## 🔒 Security Features

- JWT token authentication
- Password hashing with bcrypt
- SQL injection prevention
- XSS protection
- CSRF protection
- File upload validation
- Rate limiting
- Security headers

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/yourusername/item-exchange-platform/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/item-exchange-platform/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/item-exchange-platform/discussions)

## 🎯 Roadmap

- [ ] Mobile app (React Native)
- [ ] Push notifications
- [ ] Payment integration
- [ ] Advanced search with Elasticsearch
- [ ] Machine learning recommendations
- [ ] Multi-language support

---

**Built with ❤️ for the sharing economy**