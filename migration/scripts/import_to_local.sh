#!/bin/bash
# =====================================================
# Archon Local Database Import Script
# =====================================================
# This script imports your exported cloud data into
# the local PostgreSQL database.
#
# Prerequisites:
# 1. archon-db container must be running
# 2. migration/cloud_backup.sql must exist
# 3. POSTGRES_PASSWORD must be set in .env or .env.local
#
# Usage: ./import_to_local.sh
# =====================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Archon Local Database Import Script             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker is not running!${NC}"
    echo "Please start Docker and try again."
    exit 1
fi

# Check if archon-db container is running
if ! docker ps --format '{{.Names}}' | grep -q "^archon-db$"; then
    echo -e "${RED}ERROR: archon-db container is not running!${NC}"
    echo ""
    echo "Start the local database with:"
    echo -e "  ${YELLOW}docker compose --profile localdb up -d${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ archon-db container is running${NC}"

# Check if cloud backup file exists
BACKUP_FILE="migration/cloud_backup.sql"
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}ERROR: Backup file not found: ${BACKUP_FILE}${NC}"
    echo ""
    echo "Please run the export script first:"
    echo -e "  ${YELLOW}./migration/export_cloud_data.sh${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Cloud backup file found ($(du -h $BACKUP_FILE | cut -f1))${NC}"

# Check if complete_setup.sql exists
SETUP_FILE="migration/complete_setup.sql"
if [ ! -f "$SETUP_FILE" ]; then
    echo -e "${RED}ERROR: Setup file not found: ${SETUP_FILE}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Setup file found${NC}"
echo ""

# Load environment variables
if [ -f ".env.local" ]; then
    echo -e "${BLUE}Loading credentials from .env.local${NC}"
    export $(grep -v '^#' .env.local | grep POSTGRES_PASSWORD | xargs)
elif [ -f ".env" ]; then
    echo -e "${BLUE}Loading credentials from .env${NC}"
    export $(grep -v '^#' .env | grep POSTGRES_PASSWORD | xargs)
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
    echo -e "${YELLOW}POSTGRES_PASSWORD not found in .env or .env.local${NC}"
    read -s -p "Enter PostgreSQL password: " POSTGRES_PASSWORD
    echo ""
    if [ -z "$POSTGRES_PASSWORD" ]; then
        echo -e "${RED}ERROR: Password cannot be empty!${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║   Step 1: Initialize Database Schema               ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Run complete_setup.sql to create schema and default settings
echo "Running complete_setup.sql..."
PGPASSWORD="$POSTGRES_PASSWORD" docker exec -i archon-db psql -U postgres -d archon < "$SETUP_FILE" 2>&1 | grep -E "(CREATE|INSERT|ERROR)" || true

SETUP_STATUS=${PIPESTATUS[0]}

if [ $SETUP_STATUS -eq 0 ]; then
    echo -e "${GREEN}✓ Database schema initialized${NC}"
else
    echo -e "${RED}ERROR: Failed to initialize schema${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║   Step 2: Import Cloud Data                        ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo "Importing cloud backup..."
echo "This may take a few minutes depending on data size..."
echo ""

# Import the backup file
# NOTE: We expect some conflicts with archon_settings (from complete_setup.sql)
# The backup has DROP...IF EXISTS statements so it should handle this gracefully
PGPASSWORD="$POSTGRES_PASSWORD" docker exec -i archon-db psql -U postgres -d archon < "$BACKUP_FILE" 2>&1 | \
    grep -v "NOTICE" | \
    grep -E "(INSERT|ERROR|WARNING)" | \
    head -20 || true

IMPORT_STATUS=${PIPESTATUS[0]}

if [ $IMPORT_STATUS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Cloud data imported${NC}"
else
    echo -e "${RED}ERROR: Failed to import cloud data${NC}"
    echo ""
    echo "Check the error messages above."
    echo "Common issues:"
    echo "  - Conflicts with existing data (may be normal)"
    echo "  - Foreign key violations (check data integrity)"
    exit 1
fi

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║   Step 3: Verify Import                            ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo "Running verification checks..."
echo ""

# Run verification script
VERIFY_FILE="migration/verify_import.sql"
PGPASSWORD="$POSTGRES_PASSWORD" docker exec -i archon-db psql -U postgres -d archon < "$VERIFY_FILE" 2>&1

VERIFY_STATUS=${PIPESTATUS[0]}

echo ""
if [ $VERIFY_STATUS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Import completed successfully!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Review the table counts above"
    echo "  2. Proceed to Task 5: Create dual-environment setup"
    echo "  3. Test the application with local database"
    echo ""
else
    echo -e "${YELLOW}Warning: Some verification checks failed${NC}"
    echo "Please review the output above and check for issues."
    echo ""
fi
