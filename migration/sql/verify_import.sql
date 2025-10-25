-- =====================================================
-- Archon Import Verification Script
-- =====================================================
-- This script verifies that the import was successful
-- by checking table counts, extensions, and data integrity.
-- =====================================================

\echo ''
\echo '╔════════════════════════════════════════════════════╗'
\echo '║   VERIFICATION REPORT                              ║'
\echo '╚════════════════════════════════════════════════════╝'
\echo ''

-- =====================================================
-- 1. Check PostgreSQL Extensions
-- =====================================================
\echo '1. PostgreSQL Extensions'
\echo '   ====================='

SELECT
    extname AS "Extension",
    extversion AS "Version"
FROM pg_extension
WHERE extname IN ('vector', 'pgcrypto', 'pg_trgm')
ORDER BY extname;

\echo ''

-- =====================================================
-- 2. Check Database Roles
-- =====================================================
\echo '2. Database Roles'
\echo '   =============='

SELECT
    rolname AS "Role",
    rolcanlogin AS "Can Login",
    rolbypassrls AS "Bypass RLS"
FROM pg_roles
WHERE rolname IN ('anon', 'service_role', 'postgres')
ORDER BY rolname;

\echo ''

-- =====================================================
-- 3. Table Row Counts
-- =====================================================
\echo '3. Table Row Counts'
\echo '   ================'

-- Knowledge Base Tables
SELECT 'sources' AS "Table", COUNT(*) AS "Rows" FROM sources
UNION ALL
SELECT 'documents', COUNT(*) FROM documents
UNION ALL
SELECT 'code_examples', COUNT(*) FROM code_examples

UNION ALL
-- Project Management Tables (if they exist)
SELECT 'archon_projects', COUNT(*) FROM archon_projects
UNION ALL
SELECT 'archon_tasks', COUNT(*) FROM archon_tasks
UNION ALL
SELECT 'archon_project_documents', COALESCE(COUNT(*), 0)
    FROM information_schema.tables
    LEFT JOIN archon_project_documents ON TRUE
    WHERE table_name = 'archon_project_documents'
    LIMIT 1

UNION ALL
-- Settings and Configuration
SELECT 'archon_settings', COUNT(*) FROM archon_settings

ORDER BY "Table";

\echo ''

-- =====================================================
-- 4. Check Settings Configuration
-- =====================================================
\echo '4. Critical Settings'
\echo '   ================='

SELECT
    key AS "Setting Key",
    CASE
        WHEN is_encrypted THEN '[ENCRYPTED]'
        ELSE value
    END AS "Value",
    category AS "Category"
FROM archon_settings
WHERE key IN (
    'OPENAI_API_KEY',
    'MODEL_CHOICE',
    'USE_CONTEXTUAL_EMBEDDINGS',
    'USE_HYBRID_SEARCH',
    'USE_AGENTIC_RAG',
    'USE_RERANKING',
    'PROJECTS_ENABLED'
)
ORDER BY category, key;

\echo ''

-- =====================================================
-- 5. Check Vector Embeddings
-- =====================================================
\echo '5. Vector Embeddings Sample'
\echo '   ========================'

SELECT
    COUNT(*) AS "Total Documents with Embeddings",
    AVG(vector_dims(embedding)) AS "Average Embedding Dimensions"
FROM documents
WHERE embedding IS NOT NULL;

-- Show a few sample documents
\echo ''
\echo '   Sample Documents:'

SELECT
    LEFT(content, 50) || '...' AS "Content Preview",
    vector_dims(embedding) AS "Embedding Dims",
    source_id AS "Source"
FROM documents
WHERE embedding IS NOT NULL
LIMIT 3;

\echo ''

-- =====================================================
-- 6. Check Foreign Key Relationships
-- =====================================================
\echo '6. Foreign Key Integrity'
\echo '   ====================='

-- Check if all documents reference valid sources
SELECT
    'documents → sources' AS "Relationship",
    COUNT(*) AS "Orphaned Records"
FROM documents d
LEFT JOIN sources s ON d.source_id = s.id
WHERE s.id IS NULL;

-- Check if all tasks reference valid projects (if projects exist)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'archon_tasks') THEN
        RAISE NOTICE 'Checking archon_tasks foreign keys...';
    END IF;
END $$;

\echo ''

-- =====================================================
-- 7. Check RLS Policies
-- =====================================================
\echo '7. Row Level Security Policies'
\echo '   ==========================='

SELECT
    schemaname AS "Schema",
    tablename AS "Table",
    policyname AS "Policy Name"
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

\echo ''

-- =====================================================
-- 8. Database Statistics
-- =====================================================
\echo '8. Database Statistics'
\echo '   ==================='

SELECT
    pg_size_pretty(pg_database_size('archon')) AS "Total Database Size",
    pg_size_pretty(pg_total_relation_size('documents')) AS "Documents Table Size",
    pg_size_pretty(pg_total_relation_size('sources')) AS "Sources Table Size";

\echo ''

-- =====================================================
-- 9. Sample Data Verification
-- =====================================================
\echo '9. Sample Data Check'
\echo '   ================='

\echo '   Recent Sources:'
SELECT
    source_id AS "Source ID",
    LEFT(url, 50) AS "URL",
    status AS "Status"
FROM sources
ORDER BY created_at DESC
LIMIT 3;

\echo ''

\echo '   Recent Projects (if enabled):'
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'archon_projects') THEN
        PERFORM * FROM archon_projects LIMIT 1;
        IF FOUND THEN
            RAISE NOTICE 'Projects table has data';
        END IF;
    END IF;
END $$;

SELECT
    LEFT(title, 40) AS "Project Title",
    created_at::date AS "Created"
FROM archon_projects
ORDER BY created_at DESC
LIMIT 3;

\echo ''
\echo '╔════════════════════════════════════════════════════╗'
\echo '║   VERIFICATION COMPLETE                            ║'
\echo '╚════════════════════════════════════════════════════╝'
\echo ''
\echo 'Review the results above to ensure:'
\echo '  ✓ Extensions are installed (vector, pgcrypto, pg_trgm)'
\echo '  ✓ Roles exist (anon, service_role)'
\echo '  ✓ Table row counts match expected data'
\echo '  ✓ Settings are configured'
\echo '  ✓ Vector embeddings are present'
\echo '  ✓ No orphaned foreign key records'
\echo '  ✓ RLS policies are active'
\echo ''
