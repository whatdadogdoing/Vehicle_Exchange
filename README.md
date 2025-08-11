# Item Exchange/Sharing Platform MVP

A web application for sharing, lending, and exchanging items between users.

## Features

- **User Authentication**: Register and login with email/password
- **Item Management**: Post items with photos, descriptions, and transaction types
- **Item Browsing**: View all available items in a grid layout
- **Item Details**: View full item information and contact details
- **Contact Information**: Direct access to poster's contact details

## Tech Stack

- **Backend**: Python Flask with SQLAlchemy
- **Frontend**: React with React Router
- **Database**: SQLite (easily configurable to PostgreSQL/MySQL)
- **File Storage**: Local file system

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   venv\Scripts\activate  # On Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run the Flask server:
   ```bash
   python app.py
   ```

The backend will run on `http://localhost:5000`

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the React development server:
   ```bash
   npm start
   ```

The frontend will run on `http://localhost:3000`

## Usage

1. **Register**: Create a new account with username, email, password, and optional contact info
2. **Login**: Sign in with your email and password
3. **Browse Items**: View all available items on the home page
4. **Post Item**: Click "Post Item" to create a new listing
5. **View Details**: Click on any item to see full details and contact information

## Transaction Types

- **Lend**: Temporarily lend an item
- **Give Away**: Permanently give away an item
- **Exchange**: Trade an item for something else

## File Structure

```
Project/
├── backend/
│   ├── app.py              # Main Flask application
│   ├── requirements.txt    # Python dependencies
│   ├── .env               # Environment variables
│   └── uploads/           # Image storage directory
└── frontend/
    ├── package.json       # Node.js dependencies
    ├── public/
    │   └── index.html     # HTML template
    └── src/
        ├── App.js         # Main React component
        ├── index.js       # React entry point
        └── components/    # React components
            ├── Navbar.js
            ├── Login.js
            ├── Register.js
            ├── ItemList.js
            ├── ItemDetail.js
            └── CreateItem.js
```

## Environment Configuration

The backend uses environment variables defined in `.env`:
- `DATABASE_URL`: Database connection string
- `JWT_SECRET_KEY`: Secret key for JWT tokens
- `UPLOAD_FOLDER`: Directory for uploaded images

## Future Enhancements

- Search and filtering functionality
- In-app messaging system
- User ratings and reviews
- Transaction status tracking
- Push notifications
- Admin moderation panel# Test pipeline
