#!/usr/bin/env bash
set -euo pipefail

# --- EULA check ---
if [ "${EULA,,}" != "true" ]; then
    cat >&2 <<'EOF'

==============================================================================
  You must accept the Minecraft EULA to run this server.

  Set EULA=true in your compose.yml or docker run command after reading:
    https://account.mojang.com/documents/minecraft_eula
==============================================================================

EOF
    exit 1
fi

echo "eula=true" > /tekkit2/eula.txt

# --- Seed default server.properties on first boot ---
if [ ! -f /tekkit2/server.properties ]; then
    cat > /tekkit2/server.properties <<'EOF'
# Generated on first boot by docker-entrypoint.sh.
# Edit freely — this file is not overwritten on subsequent boots.
motd=A Tekkit 2 Server
server-port=25565
gamemode=survival
difficulty=normal
max-players=20
view-distance=10
spawn-protection=16
online-mode=true
white-list=false
enable-command-block=false
allow-flight=true
allow-nether=true
pvp=true
level-name=world
level-seed=
level-type=DEFAULT
EOF
fi

# --- Locate the Forge launchable jar ---
cd /tekkit2
FORGE_JAR=$(ls forge-*-universal.jar 2>/dev/null | head -n1)
if [ -z "$FORGE_JAR" ]; then
    FORGE_JAR=$(ls forge-1.12.2-*.jar 2>/dev/null | grep -v installer | head -n1)
fi
if [ -z "$FORGE_JAR" ]; then
    echo "ERROR: Could not find Forge server jar in /tekkit2" >&2
    ls -la /tekkit2 >&2
    exit 1
fi

echo "Launching Tekkit 2 v${TEKKIT_VERSION} with ${MEMORY} heap (jar: ${FORGE_JAR})..."

# --- Aikar's flags + launch ---
exec java \
    -Xms"${MEMORY}" -Xmx"${MEMORY}" \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -jar "${FORGE_JAR}" nogui