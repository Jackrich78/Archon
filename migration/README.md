# Archon Database Tools

Quick navigation for database setup and migration.

## Fresh Setup

**Local Database (Recommended):**
See main [README.md](../README.md) → Database Setup

**Cloud Supabase:**
See main [README.md](../README.md) → Database Setup → Alternative

## Migration

**Switching from Cloud to Local:**
Follow [`MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md) - step-by-step SOP

## Maintenance

- **Reset Database**: `sql/RESET_DB.sql`
- **Verify Installation**: `sql/verify_import.sql`
- **Backup Database**: `docker exec archon-db pg_dump -U postgres archon > backup.sql`

## Directory Structure

- `scripts/` - Automation tools (export, import, credential generation)
- `sql/` - Database schemas and maintenance scripts
