-- Initialize database for Item Exchange Platform
-- PostgreSQL initialization script

-- The database is already created by POSTGRES_DB environment variable
-- Just ensure proper encoding and settings

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'UTC';