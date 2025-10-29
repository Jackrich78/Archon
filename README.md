<p align="center">
  <img src="./archon-ui-main/public/archon-main-graphic.png" alt="Archon Main Graphic" width="853" height="422">
</p>

<p align="center">
   <a href="https://trendshift.io/repositories/13964" target="_blank"><img src="https://trendshift.io/api/badge/repositories/13964" alt="coleam00%2FArchon | Trendshift" style="width: 250px; height: 55px;" width="250" height="55"/></a>
</p>

<p align="center">
  <em>Power up your AI coding assistants with your own custom knowledge base and task management as an MCP server</em>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#whats-included">What's Included</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#upgrading">Upgrading</a> •
  <a href="#troubleshooting">Troubleshooting</a>
</p>

---

## 🎯 What is Archon?

> Archon is currently in beta! Expect things to not work 100%, and please feel free to share any feedback and contribute with fixes/new features! Thank you to everyone for all the excitement we have for Archon already, as well as the bug reports, PRs, and discussions. It's a lot for our small team to get through but we're committed to addressing everything and making Archon into the best tool it possibly can be!

Archon is the **command center** for AI coding assistants. For you, it's a sleek interface to manage knowledge, context, and tasks for your projects. For the AI coding assistant(s), it's a **Model Context Protocol (MCP) server** to collaborate on and leverage the same knowledge, context, and tasks. Connect Claude Code, Kiro, Cursor, Windsurf, etc. to give your AI agents access to:

- **Your documentation** (crawled websites, uploaded PDFs/docs)
- **Smart search capabilities** with advanced RAG strategies
- **Task management** integrated with your knowledge base
- **Real-time updates** as you add new content and collaborate with your coding assistant on tasks
- **Much more** coming soon to build Archon into an integrated environment for all context engineering

This new vision for Archon replaces the old one (the agenteer). Archon used to be the AI agent that builds other agents, and now you can use Archon to do that and more.

> It doesn't matter what you're building or if it's a new/existing codebase - Archon's knowledge and task management capabilities will improve the output of **any** AI driven coding.

## 🔗 Important Links

- **[GitHub Discussions](https://github.com/coleam00/Archon/discussions)** - Join the conversation and share ideas about Archon
- **[Contributing Guide](CONTRIBUTING.md)** - How to get involved and contribute to Archon
- **[Introduction Video](https://youtu.be/8pRc_s2VQIo)** - Getting started guide and vision for Archon
- **[Archon Kanban Board](https://github.com/users/coleam00/projects/1)** - Where maintainers are managing issues/features
- **[Dynamous AI Mastery](https://dynamous.ai)** - The birthplace of Archon - come join a vibrant community of other early AI adopters all helping each other transform their careers and businesses!

---

## Quick Start

<p align="center">
  <a href="https://youtu.be/DMXyDpnzNpY">
    <img src="https://img.youtube.com/vi/DMXyDpnzNpY/maxresdefault.jpg" alt="Archon Setup Tutorial" width="640" />
  </a>
  <br/>
  <em>📺 Click to watch the setup tutorial on YouTube</em>
  <br/>
  <a href="./archon-example-workflow">-> Example AI coding workflow in the video <-</a>
</p>

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js 18+](https://nodejs.org/) (for hybrid development mode only)
- [OpenAI API key](https://platform.openai.com/api-keys) (Gemini and Ollama are supported too!)
- (OPTIONAL) [Make](https://www.gnu.org/software/make/) (for convenient dev commands)

### Setup Instructions

1. **Clone Repository**:
   ```bash
   git clone -b stable https://github.com/coleam00/archon.git
   cd archon
   ```

   **Note:** The `stable` branch is recommended for using Archon. If you want to contribute or try the latest features, use the `main` branch with `git clone https://github.com/coleam00/archon.git`

2. **Environment Configuration**:

   ```bash
   cp .env.example .env
   ```

3. **Database Setup** (Local PostgreSQL - Recommended):

   Generate secure credentials:
   ```bash
   docker run --rm -v $(pwd)/migration:/migration node:18 node /migration/scripts/generate_jwt.js
   ```

   Copy values from `migration/generated_secrets.env.template` to `.env`:
   ```bash
   SUPABASE_URL=http://archon-postgrest:3000
   SUPABASE_SERVICE_KEY=<from generated file>
   POSTGRES_PASSWORD=<from generated file>
   JWT_SECRET=<from generated file>
   ```

   **Why local database?**
   - No cloud dependencies or costs
   - Better performance and privacy
   - No usage limits
   - Full control over your data

4. **Start Services**:

   ```bash
   docker compose --profile localdb up -d
   ```

   This starts all services including local PostgreSQL:
   - **Database**: PostgreSQL + pgvector (Port: 5433)
   - **PostgREST**: Database API layer (Port: 3000)
   - **Server**: Core API and business logic (Port: 8181)
   - **MCP Server**: Protocol interface for AI clients (Port: 8051)
   - **UI**: Web interface (Port: 3737)

   **Note:** Ports are configurable in your `.env` file.

5. **Initialize Database Schema**:

   ```bash
   docker exec -i archon-db psql -U postgres -d archon < migration/sql/complete_setup.sql
   ```

6. **Configure API Keys**:
   - Open http://localhost:3737
   - You'll automatically be brought through an onboarding flow to set your API key (OpenAI is default)

7. **Test Your Setup**:
   - **Web Crawling**: Knowledge Base → "Crawl Website" → Try https://ai.pydantic.dev/llms-full.txt
   - **Document Upload**: Knowledge Base → Upload a PDF
   - **Projects**: Projects → Create a new project and add tasks
   - **AI Integration**: MCP Dashboard → Copy connection config for your AI coding assistant

---

## What's Included

### 🧠 Knowledge Management

- **Smart Web Crawling**: Automatically detects and crawls entire documentation sites, sitemaps, and individual pages
- **Document Processing**: Upload and process PDFs, Word docs, markdown files, and text documents with intelligent chunking
- **Code Example Extraction**: Automatically identifies and indexes code examples from documentation for enhanced search
- **Vector Search**: Advanced semantic search with contextual embeddings for precise knowledge retrieval
- **Source Management**: Organize knowledge by source, type, and tags for easy filtering

### 🤖 AI Integration

- **Model Context Protocol (MCP)**: Connect any MCP-compatible client (Claude Code, Cursor, even non-AI coding assistants like Claude Desktop)
- **MCP Tools**: Comprehensive yet simple set of tools for RAG queries, task management, and project operations
- **Multi-LLM Support**: Works with OpenAI, Ollama, and Google Gemini models
- **RAG Strategies**: Hybrid search, contextual embeddings, and result reranking for optimal AI responses
- **Real-time Streaming**: Live responses from AI agents with progress tracking

### 📋 Project & Task Management

- **Hierarchical Projects**: Organize work with projects, features, and tasks in a structured workflow
- **AI-Assisted Creation**: Generate project requirements and tasks using integrated AI agents
- **Document Management**: Version-controlled documents with collaborative editing capabilities
- **Progress Tracking**: Real-time updates and status management across all project activities

### 🔄 Real-time Collaboration

- **WebSocket Updates**: Live progress tracking for crawling, processing, and AI operations
- **Multi-user Support**: Collaborative knowledge building and project management
- **Background Processing**: Asynchronous operations that don't block the user interface
- **Health Monitoring**: Built-in service health checks and automatic reconnection

---

## Architecture

### Microservices Structure

Archon uses true microservices architecture with clear separation of concerns:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend UI   │    │  Server (API)   │    │   MCP Server    │    │ Agents Service  │
│                 │    │                 │    │                 │    │                 │
│  React + Vite   │◄──►│    FastAPI +    │◄──►│    Lightweight  │◄──►│   PydanticAI    │
│  Port 3737      │    │    SocketIO     │    │    HTTP Wrapper │    │   Port 8052     │
│                 │    │    Port 8181    │    │    Port 8051    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │                        │
         └────────────────────────┼────────────────────────┼────────────────────────┘
                                  │                        │
                         ┌─────────────────┐               │
                         │    Database     │               │
                         │                 │               │
                         │   PostgreSQL    │◄──────────────┘
                         │   + pgvector    │
                         │  (Local/Cloud)  │
                         └─────────────────┘
```

### Service Responsibilities

| Service        | Location                 | Purpose                      | Key Features                                                       |
| -------------- | ------------------------ | ---------------------------- | ------------------------------------------------------------------ |
| **Frontend**   | `archon-ui-main/`        | Web interface and dashboard  | React, TypeScript, TailwindCSS, Socket.IO client                   |
| **Server**     | `python/src/server/`     | Core business logic and APIs | FastAPI, service layer, Socket.IO broadcasts, all ML/AI operations |
| **MCP Server** | `python/src/mcp_server/` | MCP protocol interface       | Lightweight HTTP wrapper, MCP tools, session management            |
| **Agents**     | `python/src/agents/`     | PydanticAI agent hosting     | Document and RAG agents, streaming responses                       |

### Core Services Reference

| Service              | Container Name   | Default URL/Port      | Purpose                                   |
| -------------------- | ---------------- | --------------------- | ----------------------------------------- |
| **Web Interface**    | archon-ui        | http://localhost:3737 | Main dashboard and controls               |
| **API Service**      | archon-server    | http://localhost:8181 | Web crawling, document processing         |
| **MCP Server**       | archon-mcp       | http://localhost:8051 | Model Context Protocol interface          |
| **Agents Service**   | archon-agents    | http://localhost:8052 | AI/ML operations, reranking               |
| **PostgreSQL** *     | archon-db        | localhost:5433        | Local database (with --profile localdb)   |
| **PostgREST** *      | archon-postgrest | http://localhost:3000 | Database API (with --profile localdb)     |

\* Only runs when using local database setup with `--profile localdb`

### Communication Patterns

- **HTTP-based**: All inter-service communication uses HTTP APIs
- **Socket.IO**: Real-time updates from Server to Frontend
- **MCP Protocol**: AI clients connect to MCP Server via SSE or stdio
- **No Direct Imports**: Services are truly independent with no shared code dependencies

### Key Architectural Benefits

- **Lightweight Containers**: Each service contains only required dependencies
- **Independent Scaling**: Services can be scaled independently based on load
- **Development Flexibility**: Teams can work on different services without conflicts
- **Technology Diversity**: Each service uses the best tools for its specific purpose

---

## 🔧 Configuration

<details>
<summary><strong>Custom Ports & Hostname</strong></summary>

### Default Ports

- **archon-ui**: 3737
- **archon-server**: 8181
- **archon-mcp**: 8051
- **archon-agents**: 8052
- **archon-db**: 5433 (local only)
- **archon-postgrest**: 3000 (local only)

### Changing Ports

To use custom ports, add these variables to your `.env` file:

```bash
# Service Ports Configuration
ARCHON_UI_PORT=3737
ARCHON_SERVER_PORT=8181
ARCHON_MCP_PORT=8051
ARCHON_AGENTS_PORT=8052
```

### Configuring Hostname

By default, Archon uses `localhost` as the hostname. Configure a custom hostname or IP address:

```bash
# Hostname Configuration
HOST=localhost  # Default

# Examples:
HOST=192.168.1.100     # Use specific IP address
HOST=archon.local      # Use custom domain
HOST=myserver.com      # Use public domain
```

This is useful when:
- Running Archon on a different machine and accessing it remotely
- Using a custom domain name for your installation
- Deploying in a network environment where `localhost` isn't accessible

After changing hostname or ports:

```bash
docker compose --profile localdb down
docker compose --profile localdb up -d --build
```

</details>

---

## 🔧 Development

### Quick Start for Developers

```bash
# Install dependencies
make install

# Start development (recommended)
make dev        # Backend in Docker, frontend local with hot reload

# Alternative: Everything in Docker
make dev-docker # All services in Docker

# Stop everything
make stop
```

### Development Modes

#### Hybrid Mode (Recommended) - `make dev`

Best for active development with instant frontend updates:
- Backend services run in Docker (isolated, consistent)
- Frontend runs locally with hot module replacement
- Instant UI updates without Docker rebuilds

#### Full Docker Mode - `make dev-docker`

For all services in Docker environment:
- All services run in Docker containers
- Better for integration testing
- Slower frontend updates

### Testing & Code Quality

```bash
# Run tests
make test       # Run all tests
make test-fe    # Run frontend tests
make test-be    # Run backend tests

# Run linters
make lint       # Lint all code
make lint-fe    # Lint frontend code
make lint-be    # Lint backend code

# Check environment
make check      # Verify environment setup

# Clean up
make clean      # Remove containers and volumes (asks for confirmation)
```

### Viewing Logs

```bash
# All services
docker compose logs -f
# OR
make logs

# Specific service
docker compose logs -f archon-server
docker compose logs -f archon-mcp
docker compose logs -f archon-ui
docker compose logs -f archon-db        # Local database only
docker compose logs -f archon-postgrest # Local database only
```

**Note**: Backend services are configured with `--reload` flag and have source code mounted as volumes for automatic hot reloading.

<details>
<summary><strong>🛠️ Installing Make (Optional)</strong></summary>

### Windows

```bash
# Option 1: Using Chocolatey
choco install make

# Option 2: Using Scoop
scoop install make

# Option 3: Using WSL2
wsl --install
# Then in WSL: sudo apt-get install make
```

### macOS

```bash
# Make comes pre-installed on macOS
# If needed: brew install make
```

### Linux

```bash
# Debian/Ubuntu
sudo apt-get install make

# RHEL/CentOS/Fedora
sudo yum install make
```

### Quick Command Reference

| Command                | Description                                             |
| ---------------------- | ------------------------------------------------------- |
| `make dev`             | Start hybrid dev (backend in Docker, frontend local) ⭐ |
| `make dev-docker`      | Everything in Docker                                    |
| `make stop`            | Stop all services (including local database)            |
| `make restart-localdb` | Restart all services with local database                |
| `make logs`            | View logs for all services                              |
| `make test`            | Run all tests                                           |
| `make lint`            | Run linters                                             |
| `make install`         | Install dependencies                                    |
| `make check`           | Check environment setup                                 |
| `make clean`           | Remove containers and volumes (with confirmation)       |

</details>

---

## Upgrading

To upgrade Archon to the latest version:

1. **Pull latest changes**:
   ```bash
   git pull
   ```

2. **Rebuild and restart containers**:

   **With Local Database:**
   ```bash
   docker compose --profile localdb up -d --build
   ```

   **With Cloud Supabase:**
   ```bash
   docker compose up -d --build
   ```

   **Using Make:**
   ```bash
   make restart-localdb  # For local database
   ```

3. **Check for database migrations**:
   - Open Archon settings: http://localhost:3737/settings
   - Navigate to **Database Migrations** section
   - If there are pending migrations, the UI will display them with clear instructions
   - Click on each migration to view and copy the SQL
   - Run the SQL scripts in order shown:
     - **Local Database**: `docker exec -i archon-db psql -U postgres -d archon < migration/sql/<migration_file>.sql`
     - **Cloud Supabase**: Run in Supabase SQL Editor

---

## Troubleshooting

### Common Issues and Solutions

#### Port Conflicts

If you see "Port already in use" errors:

```bash
# Check what's using a port (e.g., 3737)
lsof -i :3737  # macOS/Linux
netstat -ano | findstr :3737  # Windows

# Stop all Archon services
docker compose --profile localdb down
# OR
make stop

# If port 5433 (PostgreSQL) is in use:
# 1. Check what's using it: lsof -i :5433
# 2. Either stop that service or change Archon's port in docker-compose.yml
# 3. The default is 5433 to avoid conflicts with standard PostgreSQL on 5432
```

**Note:** Archon's local PostgreSQL uses port **5433** (not 5432) specifically to avoid conflicts with other PostgreSQL installations.

#### Archon Server Fails to Start ("dependency failed to start")

If you see `dependency failed to start: container archon-server is unhealthy` when running `docker compose --profile localdb up -d`:

**Symptoms:**
- archon-db and archon-postgrest show as "Healthy"
- archon-server shows as "Unhealthy"
- Logs show: `httpx.ConnectError: [Errno -2] Name or service not known`

**Solution:**
This was fixed in recent versions by adding proper service dependencies. To resolve:

```bash
# Stop all services
docker compose --profile localdb down

# Pull latest changes
git pull

# Restart with build
docker compose --profile localdb up -d --build
```

**What was fixed:** The archon-server now waits for archon-postgrest to be healthy before starting, preventing race conditions during startup.

#### Frontend Can't Connect to Backend

- Check backend is running: `curl http://localhost:8181/health`
- Verify port configuration in `.env`
- For custom ports, ensure both `ARCHON_SERVER_PORT` and `VITE_ARCHON_SERVER_PORT` are set

#### Docker Permission Issues (Linux)

If you encounter permission errors with Docker:

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and back in, or run
newgrp docker
```

#### Windows-Specific Issues

- **Make not found**: Install Make via Chocolatey, Scoop, or WSL2 (see [Installing Make](#development))
- **Line ending issues**: Configure Git to use LF endings:
  ```bash
  git config --global core.autocrlf false
  ```

#### Docker Compose Hangs

If `docker compose` commands hang:

```bash
# Reset Docker Compose
docker compose down --remove-orphans
docker system prune -f

# Restart Docker Desktop (if applicable)
```

#### Hot Reload Not Working

- **Frontend**: Ensure you're running in hybrid mode (`make dev`) for best HMR experience
- **Backend**: Check that volumes are mounted correctly in `docker-compose.yml`
- **File permissions**: On some systems, mounted volumes may have permission issues

### Checking Service Health

```bash
# List all services with status
docker compose ps

# Check API health
curl http://localhost:8181/health

# Check MCP server
curl http://localhost:8051/health
```

### Restarting Services

```bash
# Restart a specific service
docker compose restart archon-server
docker compose restart archon-mcp

# Restart all services
docker compose --profile localdb down
docker compose --profile localdb up -d
```

### Database Operations

#### Reset Database (Start Fresh)

⚠️ **WARNING**: This will delete ALL Archon data!

<details>
<summary><strong>Click to show reset instructions</strong></summary>

**For Local Database:**
```bash
docker exec -i archon-db psql -U postgres -d archon < migration/sql/RESET_DB.sql
docker exec -i archon-db psql -U postgres -d archon < migration/sql/complete_setup.sql
docker compose restart archon-server
```

**For Cloud Supabase:**
1. In your Supabase SQL Editor, run: `migration/sql/RESET_DB.sql`
2. Then run: `migration/sql/complete_setup.sql`
3. Restart services: `docker compose up -d`

**After Reset:**
- Select your LLM/embedding provider and set the API key again
- Re-upload any documents or re-crawl websites

The reset script safely removes all tables, functions, triggers, and policies with proper dependency handling.

</details>

---

## Alternative: Cloud Supabase Setup

If you prefer managed database services instead of running PostgreSQL locally:

<details>
<summary><strong>Cloud Supabase Setup Instructions</strong></summary>

**Good for:**
- Quick testing without local infrastructure
- Managed backups and scaling
- Accessing Archon from multiple locations

**Setup:**
1. Create account at [supabase.com](https://supabase.com/)
2. Create new project, get credentials from Settings → API
3. ⚠️ **Use the service_role key** (longer one), NOT the anon key!
4. Set in `.env`:
   ```bash
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-role-key-here
   ```
5. In Supabase SQL Editor, run: `migration/sql/complete_setup.sql`
6. Start services:
   ```bash
   docker compose up -d
   ```

**Migrating from Cloud to Local?** See [`migration/MIGRATION_GUIDE.md`](migration/MIGRATION_GUIDE.md)

</details>

---

## 📈 Progress

<p align="center">
  <a href="https://star-history.com/#coleam00/Archon&Date">
    <img src="https://api.star-history.com/svg?repos=coleam00/Archon&type=Date" width="500" alt="Star History Chart">
  </a>
</p>

## 📄 License

Archon Community License (ACL) v1.2 - see [LICENSE](LICENSE) file for details.

**TL;DR**: Archon is free, open, and hackable. Run it, fork it, share it - just don't sell it as-a-service without permission.
