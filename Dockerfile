# syntax=docker/dockerfile:1.7
FROM eclipse-temurin:8-jre-jammy

LABEL org.opencontainers.image.title="Tekkit 2 Server"
LABEL org.opencontainers.image.description="Tekkit 2 v1.2.6 Minecraft server (MC 1.12.2 + Forge)"
LABEL org.opencontainers.image.source="https://github.com/kremity/tekkit2-docker"
LABEL org.opencontainers.image.licenses="MIT"

ARG TEKKIT_SERVER_URL=https://servers.technicpack.net/Technic/servers/tekkit-2/Tekkit-2_Server_v1.2.6.zip
ARG TEKKIT_VERSION=1.2.6
ENV TEKKIT_VERSION=${TEKKIT_VERSION}

# Tools, fetch server zip, extract (flattening any top-level wrapper dir),
# run the Forge installer if the zip ships one, then clean up — all in one layer.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        ca-certificates \
        tini \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/tekkit2-default /tmp/extract \
 && curl -fSL "${TEKKIT_SERVER_URL}" -o /tmp/server.zip \
 && unzip -q /tmp/server.zip -d /tmp/extract \
 && cd /tmp/extract \
 && if [ "$(ls -A | wc -l)" = "1" ] && [ -d "$(ls)" ]; then \
        src="/tmp/extract/$(ls)"; \
    else \
        src="/tmp/extract"; \
    fi \
 && cp -a "$src"/. /opt/tekkit2-default/ \
 && rm -rf /tmp/extract /tmp/server.zip \
 && cd /opt/tekkit2-default \
 && if ls forge-*-universal.jar >/dev/null 2>&1; then \
        rm -f forge-*-installer.jar forge-*-installer.jar.log; \
    elif ls forge-*-installer.jar >/dev/null 2>&1; then \
        echo "Running Forge installer..." && \
        java -jar forge-*-installer.jar --installServer && \
        rm -f forge-*-installer.jar forge-*-installer.jar.log; \
    fi

ENV MEMORY=4G \
    EULA=false \
    TZ=UTC

WORKDIR /tekkit2
EXPOSE 25565/tcp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# tini handles SIGTERM properly so the JVM gets a clean shutdown on `docker stop`
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]