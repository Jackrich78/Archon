-- =====================================================
-- Archon Local Database Initialization
-- =====================================================
-- This script initializes the required PostgreSQL extensions
-- for Archon's local database setup.
--
-- Executed automatically when archon-db container starts
-- via docker-entrypoint-initdb.d mechanism
-- =====================================================

-- Enable required PostgreSQL extensions
-- These are critical for Archon's functionality

-- pgvector: Vector similarity search for RAG
CREATE EXTENSION IF NOT EXISTS vector;

-- pgcrypto: Cryptographic functions for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- pg_trgm: Trigram matching for hybrid search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create the anon role for PostgREST (if not exists)
-- This role is used for unauthenticated requests
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN;
        GRANT anon TO postgres;
    END IF;
END
$$;

-- Create the service_role for PostgREST (if not exists)
-- This role bypasses Row Level Security (RLS) policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN BYPASSRLS;
        GRANT service_role TO postgres;
    END IF;
END
$$;

-- Grant necessary permissions to roles on public schema
GRANT USAGE ON SCHEMA public TO anon, service_role;
GRANT ALL ON SCHEMA public TO service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Archon database extensions initialized successfully';
    RAISE NOTICE '  - vector: enabled';
    RAISE NOTICE '  - pgcrypto: enabled';
    RAISE NOTICE '  - pg_trgm: enabled';
    RAISE NOTICE '  - anon role: created';
    RAISE NOTICE '  - service_role: created';
END
$$;
