# Space Engineers Dedicated Debian Docker Container

First of all thanks to [7thCore](https://github.com/7thCore) and [mmmaxwwwell](https://github.com/mmmaxwwwell) for their great prework making a linux dedicated server for Space Engineers real!

I took parts of their projects to create this one (see credits)

## Features

- ✅ Vanilla Space Engineers Dedicated Server
- ✅ **Torch Server Support** (modding framework with plugin support)
- ✅ Automated builds via GitHub Actions
- ✅ Published to GitHub Container Registry (ghcr.io)
- ✅ Signed container images with cosign
- 🐧 Runs on Linux with Wine

## Documentation

- 📋 [SERVER-STATUS.md](SERVER-STATUS.md) - How to check if your server is running and troubleshooting
- ⚙️ [CONFIGURATION.md](CONFIGURATION.md) - Complete environment variable reference

## Why?

I wanted to have a more cleaner docker container with less dependencies (integrate sesrv-script parts instead of wget the whole script) and a little more configuration through composer files.

## Server Variants

This project supports two server types:

| Variant | Description | Image Tag | Use Case |
|---------|-------------|-----------|----------|
| **Vanilla** | Official SE Dedicated Server | `latest`, `master` | Standard multiplayer |
| **Torch** | Torch Server with plugin support | `master-torch` | Modded servers, admin tools |

## KeyFacts

| Key         | Vanilla              | Torch                |
| ----------- | -------------------- | -------------------- |
| OS          | Debian 12 (Bookworm) | Debian 12 (Bookworm) |
| Wine        | 9.0~bookworm-1       | 9.0~bookworm-1       |
| Docker size | ~1.82GB compressed   | ~1.82GB compressed   |
| Build Time  | ~ 19 Minutes         | ~ 19 Minutes         |

## How to use

First you have to use the `Space Engineers Dedicated Server` Tool to setup your world.

(detailed instructions follow when requested)

After you have saved your world upload it (the instance directory) to your docker host machine `/appdata/space-engineers/instances/`.

## Using Pre-built Images from GitHub Container Registry

### Vanilla Server

```yaml
services:
  se-server:
    image: ghcr.io/eliasranz/docker-spaceengineers:latest
    container_name: se-ds-docker
    restart: unless-stopped
    volumes:
      - /appdata/space-engineers/plugins:/appdata/space-engineers/plugins
      - /appdata/space-engineers/instances:/appdata/space-engineers/instances
      - /appdata/space-engineers/SpaceEngineersDedicated:/appdata/space-engineers/SpaceEngineersDedicated
      - /appdata/space-engineers/steamcmd:/root/.steam
    ports:
      - "27016:27016/udp"
      - "18080:8080/tcp"
    environment:
      - WINEDEBUG=-all
      - INSTANCE_NAME=SE
      - PUBLIC_IP=127.0.0.1
```

### Torch Server

```yaml
services:
  se-torch:
    image: ghcr.io/eliasranz/docker-spaceengineers:master-torch
    container_name: se-torch-docker
    restart: unless-stopped
    volumes:
      - /appdata/space-engineers/instances:/appdata/space-engineers/instances
      - /appdata/space-engineers/SpaceEngineersDedicated:/appdata/space-engineers/SpaceEngineersDedicated
      - /appdata/space-engineers/steamcmd:/root/.steam
    ports:
      - "27016:27016/udp"
      - "18080:8080/tcp"
    environment:
      - WINEDEBUG=-all
      - INSTANCE_NAME=SE
      - PUBLIC_IP=127.0.0.1
      # Root-level config overrides
      - SE_SERVER_NAME=My Awesome Server
      # Session settings (use SE_SESSION_ prefix)
      - SE_SESSION_MAX_PLAYERS=16
      - SE_SESSION_GAME_MODE=Survival
      # Performance plugins (see below)
      - INSTALL_CONCEALMENT=true
      - CONCEALMENT_DISTANCE=8000
```

## Torch Performance Plugins

The Torch server includes **automatic installation** of performance-optimizing plugins, ideal for servers with weak CPUs:

### Installed by Default

| Plugin | Purpose | Impact | Default |
|--------|---------|--------|---------|
| **Concealment** | Pauses grids when no players nearby | 50-90% sim speed improvement | ✅ Enabled |
| **Performance Improvements** | Viktor's optimization patches | Fixes game inefficiencies, reduces GC pressure | ✅ Enabled |
| **Essentials** | Admin tools & automated cleanup | Grid limits, trash removal | ❌ Disabled (opt-in) |

### Plugin Configuration

```yaml
environment:
  # Enable/disable plugins
  - INSTALL_CONCEALMENT=true                # Critical for weak CPUs
  - INSTALL_PERFORMANCE_IMPROVEMENTS=true   # Recommended for all servers
  - INSTALL_ESSENTIALS=false                # Optional admin tools
  
  # Concealment distance configuration
  - CONCEALMENT_DISTANCE=8000               # Distance in meters (8km default)
```

### Concealment Plugin Notes

**Benefits:**
- Dramatically improves server performance (often 2x sim speed increase)
- Reduces active grid count by 50-90%
- Essential for servers with weak CPUs

**Side Effects & Workarounds:**
- Long-distance autonomous drones may pause outside player range
  - **Solution:** Increase `CONCEALMENT_DISTANCE` (e.g., 15000 for 15km)
- Laser antennas between distant grids may disconnect
  - **Solution:** Adjust distance or exclude grids with beacons from concealment
- Grids "unconcealed" when players approach (brief activation delay)

**Configuration Examples:**

```yaml
# Default: Good balance for most servers
- CONCEALMENT_DISTANCE=8000

# Long-range automation: For servers with autonomous drones
- CONCEALMENT_DISTANCE=15000

# Disable concealment: If you prefer vanilla behavior
- INSTALL_CONCEALMENT=false
```

### Performance Improvements Plugin Notes

**Benefits:**
- Reduces memory allocations and GC pressure
- Fixes various game inefficiencies
- Minimal side effects

**Side Effects:**
- 2-second cache for safe zone/ownership changes (negligible impact)

### All Plugins are Server-Side Only

✅ Players connect with **vanilla client** - no mods required  
✅ 100% client-compatible  
✅ No extra workflow for players

## Configuration

### Auto-Discovery Config System

This project uses an **intelligent configuration system** that automatically adapts to Space Engineers updates:

- ✅ **Extracts default config** from SE installation (always up-to-date)
- ✅ **Auto-discovers valid fields** from SE's schema
- ✅ **Validates overrides** before applying
- ✅ **Warns about deprecated fields** when SE updates
- ✅ **Suggests alternatives** when fields are renamed

### Environment Variable Overrides

Override any config setting using `SE_` prefixed environment variables:

```yaml
environment:
  # Root-level settings (SE_*)
  - SE_SERVER_NAME=My Server
  - SE_SERVER_DESCRIPTION=Welcome to my server!
  - SE_WORLD_NAME=MyWorld
  - SE_SERVER_PORT=27016
  - SE_PAUSE_GAME_WHEN_EMPTY=false
  - SE_IGNORE_LAST_SESSION=true
  
  # Session settings (SE_SESSION_*)
  - SE_SESSION_GAME_MODE=Survival
  - SE_SESSION_MAX_PLAYERS=16
  - SE_SESSION_VIEW_DISTANCE=15000
  - SE_SESSION_ENABLE_SPECTATOR=false
  - SE_SESSION_ENABLE_INGAME_SCRIPTS=true
  - SE_SESSION_SHOW_PLAYER_NAMES_ON_HUD=true
```

**Naming Convention:**
- Root-level: `SE_SERVER_NAME` → `<ServerName>` in `/MyConfigDedicated/`
- Session settings: `SE_SESSION_MAX_PLAYERS` → `<MaxPlayers>` in `/MyConfigDedicated/SessionSettings/`

### See All Available Options

Set `SHOW_CONFIG_OPTIONS=true` to display all available configuration options on startup:

```yaml
environment:
  - SHOW_CONFIG_OPTIONS=true
```

### Auto-Update Config on SE Updates

When Space Engineers updates and changes the config schema:

```yaml
environment:
  - AUTO_UPDATE_CONFIG=true  # Automatically update config from SE's latest default
```

This will backup your old config and apply the new template.

### Manual Config File

Advanced users can provide their own `SpaceEngineers-Dedicated.cfg`:

1. Place your config in: `/appdata/space-engineers/instances/SE/SpaceEngineers-Dedicated.cfg`
2. Environment variables will still override specific fields
3. Container won't overwrite your custom config

## Building Locally

### Build Vanilla Server

```bash
docker build --build-arg SERVER_TYPE=vanilla -t spaceengineers:latest .
```

### Build Torch Server

```bash
docker build --build-arg SERVER_TYPE=torch -t spaceengineers:torch .
```

## Using docker-compose (Local Build)

Do not forget to rename `TestInstance` with your instance name!

### example composer - just copy and adjust

```yaml
services:
  se-server:
    image: devidian/spaceengineers:winestaging
    container_name: se-ds-docker
    restart: unless-stopped
    volumes:
      # left side: your docker-host machine
      # right side: the paths in the image (!!do not change!!)
      - /appdata/space-engineers/plugins:/appdata/space-engineers/plugins
      - /appdata/space-engineers/instances:/appdata/space-engineers/instances
      - /appdata/space-engineers/SpaceEngineersDedicated:/appdata/space-engineers/SpaceEngineersDedicated
      - /appdata/space-engineers/steamcmd:/root/.steam
    ports:
      - target: 27016
        published: 27016
        protocol: udp
        mode: host
    environment:
      - WINEDEBUG=-all
      - INSTANCE_NAME=TestInstance
      - PUBLIC_IP=1.2.3.4
      # public ip required for healthcheck
```

## Build the image yourself from source

Download this repository and run `docker-compose up -d`

## Use the docker image as source for your own image

If you want to extend the image create a `Dockerfile` and use `FROM devidian/spaceengineers:latest`

## FAQ

### Can i use plugins?

Yes just copy plugins to `/appdata/space-engineers/plugins` and they will be added or removed by the [entrypoint.sh](entrypoint.sh) script

### Can i run mods?

Yes as they are saved in your world, the server will download them on the first start.

### Can i contribute?

Sure, feel free to submit merge requests or issues if you have anything to improve this project. If you just have a question, use Github Discussions.

## Credits

| User                                                      | repo / fork                                                            | what (s)he did for this project |
| --------------------------------------------------------- | ---------------------------------------------------------------------- | ------------------------------- |
| [mmmaxwwwell](https://github.com/mmmaxwwwell)             | https://github.com/mmmaxwwwell/space-engineers-dedicated-docker-linux  | downgrading for dotnet48        |
| [7thCore](https://github.com/7thCore)                     | https://github.com/7thCore/sesrv-script                                | installer bash script           |
| [Diego Lucas Jimenez](https://github.com/tanisdlj)        | -                                                                      | Improved Dockerfile             |
| [EthicalObligation](https://github.com/EthicalObligation) | https://github.com/EthicalObligation/docker-spaceengineers-healthcheck | Healthcheck & Quicker startup   |
| [draconb](https://github.com/draconb)                     | -                                                                      | Hints for plugin support        |

## Known issues

- **Torch Plugin Downloads**
  - TorchAPI.com plugin download URLs are currently returning 404 errors (as of December 2024)
  - **Performance Improvements plugin**: ✅ **Automatically downloaded** from GitHub releases
  - **Concealment plugin**: ⚠️ Manual installation required (not available on GitHub)
    - Check [TorchAPI page](https://torchapi.com/plugins/view/17f44521-b77a-4e85-810f-ee73311cf75d) or SE Mods Discord
  - Other plugins: Check [TorchAPI.com/plugins](https://torchapi.com/plugins) for GitHub links
  - The server will start successfully without plugins (they're optional optimizations)
  
- **VRage Remote Client**
  - Connection issues reported - if you get it working, please share! [See issue](https://github.com/Devidian/docker-spaceengineers/issues/36)
