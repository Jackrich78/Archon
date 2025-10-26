# Cloud to Local Migration - Standard Operating Procedure

**Last tested**: 2025-10-25
**Migration time**: ~30 minutes
**Difficulty**: Intermediate

## What This Does

Migrates your Archon instance from cloud Supabase to local PostgreSQL while preserving:
- All knowledge base sources and documents
- All projects and tasks
- All settings and API keys
- Complete search functionality

## Prerequisites

- [ ] Docker Desktop running
- [ ] At least 2GB free disk space
- [ ] Current `.env` file with cloud credentials
- [ ] 30 minutes of uninterrupted time

---

## Step 1: Export Cloud Data (5 minutes)

```bash
cd archon
./migration/scripts/export_cloud_data.sh
```

This creates `migration/cloud_export.sql` with your data.

**Verify export:**
```bash
ls -lh migration/cloud_export.sql
# Should show file size > 1MB if you have data
```

---

## Step 2: Generate Local Credentials (2 minutes)

```bash
docker run --rm -v $(pwd)/migration:/migration node:18 node /migration/scripts/generate_jwt.js
```

**Verify generated:**
```bash
cat migration/generated_secrets.env.template
# Should show 3 values: POSTGRES_PASSWORD, JWT_SECRET, JWT_TOKEN_SERVICE_ROLE
```

---

## Step 3: Setup Local Database (5 minutes)

### 3.1 Update `.env` file

Replace cloud values with:
```bash
SUPABASE_URL=http://archon-postgrest:3000
SUPABASE_SERVICE_KEY=<JWT_TOKEN_SERVICE_ROLE from generated_secrets.env.template>
POSTGRES_PASSWORD=<from generated_secrets.env.template>
JWT_SECRET=<from generated_secrets.env.template>
```

**Important:** Local PostgreSQL runs on port **5433** (not 5432) to avoid conflicts with other databases.

### 3.2 Start local database

```bash
docker compose --profile localdb up -d archon-db archon-postgrest
```

**Verify running:**
```bash
docker compose ps
# archon-db should show "healthy" on port 5433
# archon-postgrest should show "running" on port 3000
```

---

## Step 4: Import Your Data (10 minutes)

```bash
./migration/scripts/import_to_local.sh
```

This will:
1. Initialize database schema
2. Import your cloud data
3. Run verification checks

**Look for this output:**
```
✓ Database schema initialized
✓ Cloud data imported
✓ Imported X settings, Y sources, Z documents
```

---

## Step 5: Fix Client Connection (CRITICAL)

**Why this step?** Python's `credential_service.py` needs to use the shared client manager to properly handle local PostgREST.

**Already done in your repo!** The fix from 2025-10-25 is in place:
- `credential_service.py` lines 23, 61 use `client_manager.get_supabase_client()`
- This ensures local PostgREST URL doesn't get `/rest/v1` appended

**If you're doing this fresh, apply:**

File: `python/src/server/services/credential_service.py`

Line 23, add import:
```python
from .client_manager import get_supabase_client as get_shared_supabase_client
```

Line 61, replace `create_client()` with:
```python
self._supabase = get_shared_supabase_client()
```

---

## Step 6: Start All Services (3 minutes)

```bash
docker compose --profile localdb up -d
```

**Verify all healthy:**
```bash
docker compose ps
# All services should show "healthy" status
```

---

## Step 7: Verify Migration (5 minutes)

### 7.1 Check health

```bash
curl http://localhost:8181/health
# Should show: "status":"healthy", "credentials_loaded":true
```

### 7.2 Check data in UI

1. Open http://localhost:3737
2. Go to Knowledge Base → should see your sources
3. Go to Projects → should see your projects and tasks
4. Try a search → should return results

### 7.3 Test database directly

```bash
docker exec archon-db psql -U postgres -d archon -c "SELECT COUNT(*) FROM archon_settings;"
# Should show 46
```

---

## Step 8: Pause Cloud Database

Once verified working for 24 hours:

1. Go to Supabase dashboard → Project Settings → General
2. Click "Pause project"
3. Verify Archon still works locally

**If issues:** Unpause cloud, check logs: `docker compose logs archon-server`

---

## Troubleshooting

### "PGRST125: Invalid path" error

**Cause**: Old code bypass of client_manager
**Fix**: Apply Step 5 (client connection fix)

### "No data showing"

**Cause**: Import didn't complete
**Fix**: Re-run `./migration/scripts/import_to_local.sh`

### "Connection refused"

**Cause**: PostgREST not running
**Fix**: `docker compose restart archon-postgrest`

### Services won't start

**Cause**: Wrong credentials in `.env`
**Fix**: Verify all 4 values from `generated_secrets.env.template`

### "Failed to decrypt credential"

**Cause**: Encryption key changed (expected during migration)
**Effect**: OpenAI API key needs to be re-entered in Settings
**Fix**: Open http://localhost:3737 → Settings → Re-enter OpenAI API key

---

## Rollback to Cloud

If needed, revert:

1. Restore cloud credentials in `.env`
2. Stop local database: `docker compose --profile localdb down`
3. Start without localdb: `docker compose up -d`
4. Unpause cloud Supabase project

---

## Success Checklist

- [ ] All 46 settings loaded
- [ ] Knowledge sources visible in UI
- [ ] Projects and tasks visible
- [ ] Search returns results
- [ ] MCP server connects
- [ ] Cloud database paused, Archon still works

---

## What We Learned

### The Critical Fix

`credential_service.py` was calling `create_client()` directly, which adds `/rest/v1` to URLs - breaking local PostgREST at root path. Using `client_manager.get_supabase_client()` detects local PostgREST and creates a direct client without the path prefix.

### Key Insight

All services should use `client_manager.get_supabase_client()` for database connections, not create their own clients. This ensures proper handling of both cloud Supabase and local PostgREST.

### Root Cause Analysis

**Problem**: `PGRST125: Invalid path specified in request URL`

**Why it happened**:
1. `supabase-py`'s `create_client()` automatically appends `/rest/v1` to any URL
2. Cloud Supabase serves PostgREST at `https://xxx.supabase.co/rest/v1/` ✅
3. Local PostgREST serves at `http://archon-postgrest:3000/` (no `/rest/v1`) ✅
4. When `credential_service.py` used `create_client()` with local URL, it tried `http://archon-postgrest:3000/rest/v1/table_name` ❌

**Solution**: Use `client_manager.get_supabase_client()` which:
- Detects "archon-postgrest" in URL
- Creates `SyncPostgrestClient` directly (no path modification)
- Works for both cloud and local seamlessly

---

## Next Steps

After successful migration:

1. **Monitor for 24-48 hours** - Ensure stability
2. **Delete cloud backup** - Free up 577MB disk space (optional)
3. **Setup automated backups** - See migration/README.md
4. **Share your experience** - Help others migrate: [GitHub Discussions](https://github.com/coleam00/Archon/discussions)

---

## Important Notes

### Port Configuration

- **PostgreSQL**: Runs on port **5433** (not 5432) to avoid conflicts
- **PostgREST**: Runs on port **3000**
- If you need to change the PostgreSQL port, edit `docker-compose.yml` line 22

### Managing Your Local Database

**Always use the `--profile localdb` flag:**
```bash
# Start
docker compose --profile localdb up -d

# Stop
docker compose --profile localdb down

# Restart
docker compose --profile localdb restart archon-db

# View logs
docker compose logs -f archon-db archon-postgrest
```

**Or use the Makefile shortcuts:**
```bash
make restart-localdb  # Restart all services with database
make stop             # Automatically includes all profiles
make db-logs          # View database logs
```
