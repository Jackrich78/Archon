#!/bin/bash
# =====================================================
# Archon Cloud Supabase Data Export Script
# =====================================================
# This script exports your data from cloud Supabase
# to a local SQL file for migration to local PostgreSQL.
#
# Usage: ./export_cloud_data.sh
# =====================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Archon Cloud Supabase Data Export Script        ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo ""

# Check if pg_dump is installed
if ! command -v pg_dump &> /dev/null; then
    echo -e "${RED}ERROR: pg_dump is not installed!${NC}"
    echo ""
    echo "Please install PostgreSQL client tools:"
    echo "  macOS:   brew install postgresql"
    echo "  Ubuntu:  sudo apt-get install postgresql-client"
    echo "  Windows: Download from https://www.postgresql.org/download/"
    exit 1
fi

echo -e "${YELLOW}You will need the following information from your Supabase dashboard:${NC}"
echo "  1. Project Reference (found in dashboard URL)"
echo "  2. Database Password (Settings → Database → Database password)"
echo ""
echo -e "${BLUE}See migration/EXPORT_INSTRUCTIONS.md for detailed help.${NC}"
echo ""

# Prompt for Supabase project reference
read -p "Enter your Supabase project reference (e.g., 'abcd1234efgh'): " PROJECT_REF

if [ -z "$PROJECT_REF" ]; then
    echo -e "${RED}ERROR: Project reference cannot be empty!${NC}"
    exit 1
fi

# Construct database host based on connection type
echo ""
echo -e "${YELLOW}Choose connection method:${NC}"
echo "  1. Direct connection (db.${PROJECT_REF}.supabase.co)"
echo "  2. Session Pooler (for IPv4 networks)"
echo ""
read -p "Enter choice (1 or 2): " CONNECTION_CHOICE

if [ "$CONNECTION_CHOICE" = "2" ]; then
    # Use Session Pooler - but we need the full pooler URL
    echo ""
    echo -e "${YELLOW}Using Session Pooler connection${NC}"
    echo ""
    echo "Go to your Supabase Dashboard → Settings → Database"
    echo "Under 'Connection string', select 'Session pooler'"
    echo ""
    read -p "Enter the pooler host (e.g., aws-0-us-east-1.pooler.supabase.com): " POOLER_HOST
    DB_HOST="$POOLER_HOST"
    DB_PORT=6543  # Pooler uses port 6543
    DB_USER="postgres.${PROJECT_REF}"  # Pooler requires full username
else
    # Use direct connection
    DB_HOST="db.${PROJECT_REF}.supabase.co"
    DB_PORT=5432
    DB_USER="postgres"
fi

echo ""
echo -e "${GREEN}Database Host: ${DB_HOST}${NC}"
echo ""

# Prompt for database password (hidden input)
read -s -p "Enter your database password: " DB_PASSWORD
echo ""

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}ERROR: Database password cannot be empty!${NC}"
    exit 1
fi

# Output file
OUTPUT_FILE="migration/cloud_backup.sql"

echo ""
echo -e "${YELLOW}Starting export...${NC}"
echo ""
echo "  Database: postgres"
echo "  Host:     ${DB_HOST}"
echo "  Port:     ${DB_PORT}"
echo "  User:     ${DB_USER}"
echo "  Schema:   public"
echo "  Output:   ${OUTPUT_FILE}"
echo ""

# Export the database
# Flags explained:
#   -h: host
#   -p: port
#   -U: username
#   -d: database name
#   -n: schema to export (public only)
#   --no-owner: Don't output commands to set ownership
#   --no-acl: Don't output commands to set access privileges
#   --clean: Add DROP statements before CREATE
#   --if-exists: Use IF EXISTS for DROP statements
#   --inserts: Use INSERT statements instead of COPY (more portable)
#   -f: output file

PGPASSWORD="$DB_PASSWORD" pg_dump \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d postgres \
    -n public \
    --no-owner \
    --no-acl \
    --clean \
    --if-exists \
    --inserts \
    -f "$OUTPUT_FILE" 2>&1

EXPORT_STATUS=$?

if [ $EXPORT_STATUS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Export completed successfully!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Backup file created:${NC} ${OUTPUT_FILE}"

    # Get file size
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo -e "${BLUE}File size:${NC} ${FILE_SIZE}"

    # Count number of INSERT statements as a rough estimate of data rows
    INSERT_COUNT=$(grep -c "^INSERT INTO" "$OUTPUT_FILE" || echo "0")
    echo -e "${BLUE}Approximate data rows:${NC} ${INSERT_COUNT}"

    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Verify the backup file: cat ${OUTPUT_FILE} | head -50"
    echo "  2. Proceed to Task 4: Import data to local database"
    echo "  3. See migration/IMPORT_INSTRUCTIONS.md for import steps"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   Export failed!                                   ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo "  1. Incorrect project reference"
    echo "  2. Incorrect database password"
    echo "  3. Network connectivity issues"
    echo "  4. Firewall blocking port 5432"
    echo ""
    echo "Please check your credentials and try again."
    echo "See migration/EXPORT_INSTRUCTIONS.md for troubleshooting."
    exit 1
fi
