# Install Agenta in Docker

<https://docs.agenta.ai/self-host/quick-start>

## Quick Setup (Port 80)

```bash
git clone https://github.com/Agenta-AI/agenta && cd agenta
cp hosting/docker-compose/oss/env.oss.gh.example hosting/docker-compose/oss/.env.oss.gh

docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml --env-file hosting/docker-compose/oss/.env.oss.gh --profile with-web --profile with-traefik up -d

docker logs agenta-oss-gh-web-1
docker logs agenta-oss-gh-api-1
```

<http://localhost>

## Using a Custom Port

```edit .evn.oss.gh
TRAEFIK_PORT=90
AGENTA_SERVICES_URL=http://localhost:90/services
AGENTA_API_URL=http://localhost:90/api
AGENTA_WEB_URL=http://localhost:90
```

```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml --env-file hosting/docker-compose/oss/.env.oss.gh --profile with-web --profile with-traefik restart 
```

<http://localhost>
