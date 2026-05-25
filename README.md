# Tekkit 2 Docker

An unofficial Docker image for running a [Tekkit 2](https://www.technicpack.net/modpack/tekkit-2.1935271)
Minecraft server, built on `eclipse-temurin:8-jre-jammy` with [Aikar's flags](https://docs.papermc.io/paper/aikars-flags)
for smoother tick rates on entity-heavy bases.

Tekkit 2 is a Minecraft 1.12.2 modpack by [xJon](https://www.technicpack.net/profile/xjon),
distributed through the [Technic Platform](https://www.technicpack.net/). This image bundles
the official server files from Technic's CDN. All credit for the modpack itself goes to xJon
and the individual mod authors.

## Tags

| Tag      | Tekkit 2 version | Minecraft | Forge       |
|----------|------------------|-----------|-------------|
| `1.2.6`  | 1.2.6            | 1.12.2    | bundled     |
| `latest` | 1.2.6            | 1.12.2    | bundled     |

## Quick start

```bash
mkdir -p /srv/tekkit2 && cd /srv/tekkit2
curl -O https://raw.githubusercontent.com/kremity/tekkit2-docker/main/compose.yml
# edit compose.yml — at minimum confirm EULA=true and adjust MEMORY
docker compose up -d
```

The server will be reachable on port 25565. First boot takes 2–4 minutes
while Forge loads all the mods.

## Configuration

### Environment variables

| Variable | Default | Description                                                           |
|----------|---------|-----------------------------------------------------------------------|
| `EULA`   | `false` | Must be `true` to start. Implies you accept the Minecraft EULA.       |
| `MEMORY` | `4G`    | JVM heap (both `-Xms` and `-Xmx`). 6G recommended for active play.    |
| `TZ`     | `UTC`   | Container timezone, e.g. `Europe/Amsterdam`.                          |

### server.properties

On first boot a sensible default `server.properties` is written into the
bind-mounted directory. Edit it freely — it won't be overwritten on subsequent
boots. Restart the container to pick up changes.

### Ops, whitelist, bans

Edit `ops.json`, `whitelist.json`, `banned-players.json` in the bind-mounted
directory, or use the server console (see below).

## Server console

```bash
docker attach tekkit2
```

Detach with `Ctrl+P` then `Ctrl+Q`. `Ctrl+C` will kill the JVM — don't.

## Backups

Everything (world, configs, logs, mods) lives in the bind-mounted directory.
To back up:

```bash
docker compose stop
tar czf tekkit2-backup-$(date +%F).tar.gz -C /mnt/data tekkit2
docker compose start
```

## Memory sizing

Tekkit 2 on an idle server with 2-3 players uses ~3–4 GB. Heavy automation,
many chunks loaded, or 5+ players: 6–8 GB. Don't oversubscribe your host —
the JVM allocates the full `-Xmx` early and Linux will OOM-kill if RAM gets
tight.

## Building from source

```bash
git clone https://github.com/kremity/tekkit2-docker.git
cd tekkit2-docker
docker build -t kremity/tekkit2:1.2.6 .
```

## Licensing

The Dockerfile, entrypoint, and compose file in this repository are MIT-licensed
(see `LICENSE`). The Tekkit 2 modpack itself and its bundled mods are not covered
by this license — they are downloaded from Technic at build time under their
respective upstream licenses.

## Acknowledgements

- [xJon](https://www.technicpack.net/profile/xjon) and the Technic team for Tekkit 2
- All Tekkit 2 mod authors
- Daniel "Aikar" Ennis for the JVM flag set
- [variaaa/tekkit-2-server](https://hub.docker.com/r/variaaa/tekkit-2-server)
  and [gregdock97/tekkit2-server](https://hub.docker.com/r/gregdock97/tekkit2-server)
  for prior art