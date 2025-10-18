# Install Agenta in Docker

<https://docs.agenta.ai/self-host/quick-start>

## Quick Setup (Port 80)

```bash
git clone https://github.com/Agenta-AI/agenta && cd agenta
cp hosting/docker-compose/oss/env.oss.gh.example hosting/docker-compose/oss/.env.oss.gh
```

## **Edit** hosting/docker-compose/oss/.env.oss.gh & hosting/docker-compose/oss/docker-compose.gh.yml

```bash
docker compose -f hosting/docker-compose/oss/docker-compose.gh.yml --env-file hosting/docker-compose/oss/.env.oss.gh --profile with-web --profile with-traefik up -d

docker logs agenta-oss-gh-web-1

   [entrypoint.sh] Starting entrypoint script...
   [entrypoint.sh] Current working directory: /app
   [entrypoint.sh] Initial AGENTA_LICENSE: oss
   [entrypoint.sh] Using AGENTA_LICENSE: oss
   [entrypoint.sh] Creating oss/public/__env.js with the following content:
   [entrypoint.sh] Finished writing env file. Executing: sh -c node ./oss/server.js
      ▲ Next.js 15.5.2
      - Local:        http://cc501d336383:3000
      - Network:      http://cc501d336383:3000

   ✓ Starting...
   ✓ Ready in 15.7s

docker logs agenta-oss-gh-api-1

   2025-10-18T10:50:25.653Z [INFO.] PostHog initialized with host https://app.posthog.com: [oss.src.services.analytics_service]
   2025-10-18T10:51:07.994Z [INFO.] PostHog initialized with host https://app.posthog.com [oss.src.apis.fastapi.observability.router]
   2025-10-18T10:51:16.074Z [INFO.] Agenta - SDK version: 0.55.2 [agenta.sdk.agenta_init]
   2025-10-18T10:51:16.074Z [INFO.] Agenta - SDK version: 0.55.2 [agenta.sdk.agenta_init]
   2025-10-18T10:51:16.075Z [INFO.] Agenta - Host: http://host.docker.internal:7600 [agenta.sdk.agenta_init]
   2025-10-18T10:51:16.075Z [INFO.] Agenta - Host: http://host.docker.internal:7600 [agenta.sdk.agenta_init]
   2025-10-18T10:51:16.075Z [INFO.] Agenta - OLTP URL: http://host.docker.internal:7600/api/otlp/v1/traces [agenta.sdk.tracing.tracing]
   2025-10-18T10:51:16.075Z [INFO.] Agenta - OLTP URL: http://host.docker.internal:7600/api/otlp/v1/traces [agenta.sdk.tracing.tracing]

docker logs -f agenta-oss-gh-traefik-1
   time="2025-10-18T10:48:33Z" level=info msg="Configuration loaded from flags."
   
docker logs -f agenta-oss-gh-supertokens-1
   Picked up _JAVA_OPTIONS: -Djava.io.tmpdir=/lib/supertokens/temp/
   Picked up _JAVA_OPTIONS: -Djava.io.tmpdir=/lib/supertokens/temp/
   Loading supertokens config.
   Completed config.yaml loading.
   Loading supertokens version.yaml file.
   Loading storage layer.
   Loading PostgreSQL config.
   Setting up PostgreSQL connection pool.
   Setting up PostgreSQL connection pool.
   Started SuperTokens on 0.0.0.0:3567 with PID: 29
   Picked up _JAVA_OPTIONS: -Djava.io.tmpdir=/lib/supertokens/temp/
   Picked up _JAVA_OPTIONS: -Djava.io.tmpdir=/lib/supertokens/temp/
   Loading supertokens config.
   Completed config.yaml loading.
   Loading supertokens version.yaml file.
   Loading storage layer.
   Loading PostgreSQL config.
   Setting up PostgreSQL connection pool.
   Setting up PostgreSQL connection pool.
   Started SuperTokens on 0.0.0.0:3567 with PID: 30
```

```bash
curl -s http://localhost:3567/hello
   Hello

curl -s http://localhost:7600/api/health
   {"status":"ok"}   
```

<http://localhost:7600>
<http://localhost:7600/api/docs>
<http://localhost:8080/dashboard/>
