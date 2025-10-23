# Agenta OSS Setup Guide

This guide provides step-by-step instructions to set up Agenta OSS (Open Source Software) and fix the "exec format error" issues.

## Prerequisites

- Docker and Docker Compose installed
- Git installed
- System: Windows with WSL2, Linux, or macOS
- Architecture: x86_64 (amd64)
- At least 4GB free disk space

---

## Problem Overview

The Agenta repository has two issues that cause "exec format error":

1. **Dockerfile Bug:** `web/oss/docker/Dockerfile.gh` tries to copy a non-existent `.husky` directory, causing build failures
2. **Pre-built Images:** The docker-compose file is configured to pull pre-built images from GitHub that contain the bug

**Solution:** Fix the Dockerfile AND enable local builds. Both changes are required.

---

## Setup Instructions

### Step 1: Navigate to Repository

```bash
cd D:\development\PromptEngineering\agenta
```

### Step 2: Fix the Dockerfile Bug

**Option A - Manual Edit:**

Edit the file:
```bash
nano web/oss/docker/Dockerfile.gh
```

Find line 23 and **delete** this line:
```dockerfile
COPY ./.husky /app/.husky
```

Save and exit (Ctrl+O, Enter, Ctrl+X for nano).

**Option B - Automatic Fix:**

```bash
sed -i '/COPY \.\/\.husky \/app\/\.husky/d' web/oss/docker/Dockerfile.gh
```

### Step 3: Verify the Fix

```bash
git diff web/oss/docker/Dockerfile.gh
```

Should show:
```diff
-COPY ./.husky /app/.husky
```

### Step 4: Verify License Configuration

```bash
cat hosting/docker-compose/oss/.env.oss.gh | grep AGENTA_LICENSE
```

Should output: `AGENTA_LICENSE=oss` (already configured correctly)

### Step 5: Clean Up Old Images (If Any)

```bash
# Stop any running services
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik down

# Remove old images
docker rmi ghcr.io/agenta-ai/agenta-web:latest 2>/dev/null || true
docker rmi ghcr.io/agenta-ai/agenta-api:latest 2>/dev/null || true
docker rmi ghcr.io/agenta-ai/agenta-chat:latest 2>/dev/null || true
docker rmi ghcr.io/agenta-ai/agenta-completion:latest 2>/dev/null || true
```

### Step 6: Enable Local Builds (REQUIRED)

**Why this step is required:** Without uncommenting the build section, Docker will download the pre-built image from GitHub which contains the bug. You must enable local building to use your fixed Dockerfile.

Edit the docker-compose configuration:
```bash
nano hosting/docker-compose/oss/docker-compose.gh.yml
```

Find the `web` service section (around lines 4-12) and **uncomment** the build lines:

**Before:**
```yaml
    web:
        profiles:
            - with-web

        # build:
        #     context: ../../../web
        #     dockerfile: oss/docker/Dockerfile.gh

        image: ghcr.io/agenta-ai/${AGENTA_WEB_IMAGE_NAME:-agenta-web}:${AGENTA_WEB_IMAGE_TAG:-latest}
```

**After:**
```yaml
    web:
        profiles:
            - with-web

        build:
            context: ../../../web
            dockerfile: oss/docker/Dockerfile.gh

        image: ghcr.io/agenta-ai/${AGENTA_WEB_IMAGE_NAME:-agenta-web}:${AGENTA_WEB_IMAGE_TAG:-latest}
```

**Or use this automated command:**

```bash
sed -i 's/^[[:space:]]*# build:/        build:/' hosting/docker-compose/oss/docker-compose.gh.yml
sed -i 's/^[[:space:]]*#[[:space:]]*context:/            context:/' hosting/docker-compose/oss/docker-compose.gh.yml
sed -i 's/^[[:space:]]*#[[:space:]]*dockerfile:/            dockerfile:/' hosting/docker-compose/oss/docker-compose.gh.yml
```

### Step 7: Build All Services

This step will take 10-15 minutes:

```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik \
  build --force-rm web api completion chat
```

**What happens during build:**
- Downloads base Node.js and Python images
- Installs dependencies (npm, pip packages)
- Compiles the web application
- Creates optimized Docker images

### Step 8: Start All Services

```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik \
  up -d
```

### Step 9: Verify Services Are Running

Wait 30 seconds for services to initialize, then check:

```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  ps
```

**Expected output - all services should show "Up":**

```
NAME                          STATUS
agenta-oss-gh-api-1          Up X seconds
agenta-oss-gh-cache-1        Up X seconds (healthy)
agenta-oss-gh-chat-1         Up X seconds
agenta-oss-gh-completion-1   Up X seconds
agenta-oss-gh-postgres-1     Up X seconds (healthy)
agenta-oss-gh-rabbitmq-1     Up X seconds
agenta-oss-gh-redis-1        Up X seconds
agenta-oss-gh-supertokens-1  Up X seconds (healthy)
agenta-oss-gh-traefik-1      Up X seconds
agenta-oss-gh-web-1          Up X seconds
agenta-oss-gh-worker-1       Up X seconds
```

### Step 10: Check Service Logs (Optional)

Verify no "exec format error" messages:

```bash
# Check web service
docker logs agenta-oss-gh-web-1 --tail 20

# Check API service
docker logs agenta-oss-gh-api-1 --tail 20

# Check worker service
docker logs agenta-oss-gh-worker-1 --tail 20
```

**Healthy logs should show:**
- Web: `✓ Ready in [time]ms`
- API: `INFO: Application startup complete`
- Worker: List of registered Celery tasks

### Step 11: Access Agenta

Open your web browser and go to:

**Main Application:**
```
http://localhost
```

**Other endpoints:**
- API Documentation: http://localhost/api/docs
- Traefik Dashboard: http://localhost:8080
- RabbitMQ Management: http://localhost:15672 (username: `guest`, password: `guest`)

---

## Troubleshooting

### Services Keep Restarting

Check logs for the specific service:
```bash
docker logs agenta-oss-gh-<service-name>-1
```

Common issues:
- **"exec format error"** = Need to rebuild locally (follow steps 5-8)
- **Port conflicts** = Another service is using the port, change ports in `.env.oss.gh`
- **Database connection errors** = Check postgres logs: `docker logs agenta-oss-gh-postgres-1`

### Alembic Service Fails

The alembic service may exit with code 255 on first run. This is typically a database migration issue and won't affect other services. The main services (web, api, worker) should still function.

### Build Fails with "Out of Space"

Free up Docker space:
```bash
docker system prune -a --volumes
```

Then retry the build.

### Cannot Access http://localhost

Check if Traefik is running:
```bash
docker logs agenta-oss-gh-traefik-1
```

Verify port 80 is not in use by another application:
```bash
# Windows
netstat -ano | findstr :80

# Linux/Mac
lsof -i :80
```

### Reset Everything

If you need to start fresh:
```bash
# Stop and remove everything
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik down -v

# Remove all Agenta images
docker images | grep agenta | awk '{print $3}' | xargs docker rmi -f

# Start from Step 5
```

---

## Quick Reference Commands

### Start Agenta
```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik \
  up -d
```

### Stop Agenta
```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik \
  down
```

### Check Service Status
```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  ps
```

### View All Logs (Live)
```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  logs -f
```

### Restart Specific Service
```bash
docker restart agenta-oss-gh-<service-name>-1
```

### Rebuild After Code Changes
```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml \
  --env-file hosting/docker-compose/oss/.env.oss.gh \
  --profile with-web --profile with-traefik \
  build --no-cache <service-name>
```

---

## Summary of Changes Made

### Required Code Changes (2 files):

1. **`web/oss/docker/Dockerfile.gh:23`** - Removed line `COPY ./.husky /app/.husky`
   - **Why:** The `.husky` directory doesn't exist, causing build failures

2. **`hosting/docker-compose/oss/docker-compose.gh.yml:8-10`** - Uncommented build section for web service
   - **Why:** Forces Docker to build locally using your fixed Dockerfile instead of downloading the broken pre-built image from GitHub

### No Changes Needed:
- **`.env.oss.gh`** - Already has `AGENTA_LICENSE=oss` configured correctly

---

## Support

If you encounter issues not covered in this guide:

1. Check the official Agenta documentation: https://docs.agenta.ai
2. Search or create an issue on GitHub: https://github.com/Agenta-AI/agenta/issues
3. Join the Agenta community Discord for help

---

**Your Agenta OSS installation is now complete and running!** 🎉
