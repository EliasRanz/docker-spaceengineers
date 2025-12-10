# Space Engineers Docker Server Configuration Guide

## Table of Contents
- [Configuration Overview](#configuration-overview)
- [Root-Level Settings](#root-level-settings)
- [Session Settings](#session-settings)
- [Performance Tuning](#performance-tuning)
- [Torch Plugins](#torch-plugins)
- [Example Configurations](#example-configurations)

## Configuration Overview

Space Engineers server configuration is stored in XML format at `/MyConfigDedicated`. The configuration has two levels:

1. **Root-Level Settings** (`/MyConfigDedicated/*`) - Server identity, network, and operational settings
2. **Session Settings** (`/MyConfigDedicated/SessionSettings/*`) - Gameplay, world, and player settings

Environment variables use the following prefixes:
- `SE_*` for root-level settings (e.g., `SE_SERVER_NAME`)
- `SE_SESSION_*` for session settings (e.g., `SE_SESSION_MAX_PLAYERS`)

### Creating Your Configuration

**Recommended Approach:**
1. Use the Space Engineers Dedicated Server GUI tool to configure your world
2. Save the configuration (generates `SpaceEngineers-Dedicated.cfg`)
3. Place it in your instance directory: `/appdata/space-engineers/instances/<INSTANCE_NAME>/Instance/`
4. The XML file becomes your source of truth
5. Use environment variables only to override specific settings

## Root-Level Settings

These settings control server identity, network configuration, and operational parameters. They map to `/MyConfigDedicated/*` in the XML.

```yaml
# Server Identity
SE_SERVER_NAME: "My Server Name"           # Server name shown in browser
SE_WORLD_NAME: "MyWorld"                   # World/save name
SE_SERVER_DESCRIPTION: "Description"       # Server description

# Network Configuration
SE_IP: "0.0.0.0"                          # Server IP address
SE_SERVER_PORT: 27016                      # Game port (UDP)
SE_STEAM_PORT: 8766                        # Steam query port (UDP)

# Access Control
SE_GROUP_ID: 0                             # Steam Group ID (0 = none)
SE_ADMINISTRATORS: "steam64id1,steam64id2" # Admin Steam64 IDs (comma-separated)
SE_BANNED: "steam64id3"                    # Banned Steam64 IDs (comma-separated)
SE_RESERVED: "steam64id4"                  # Reserved slot Steam64 IDs

# World Loading
SE_PREMADE_CHECKPOINT_PATH: "Content/CustomWorlds/Star System" # Starting world path
SE_LOAD_WORLD: ""                          # Path to existing save to load

# Server Behavior
SE_PAUSE_GAME_WHEN_EMPTY: false           # Pause simulation when no players
SE_IGNORE_LAST_SESSION: false              # Start fresh each time
SE_CROSS_PLATFORM: false                   # Enable Xbox crossplay

# Remote API
SE_REMOTE_API_ENABLED: true                # Enable remote management API
SE_REMOTE_API_PORT: 8080                   # API port
SE_REMOTE_SECURITY_KEY: ""                 # API authentication key

# Auto-Update & Restart
### Game Mode & World

```yaml
SE_SESSION_GAME_MODE: Survival                    # Survival or Creative
SE_SESSION_ONLINE_MODE: PUBLIC                    # PUBLIC, PRIVATE, FRIENDS
SE_SESSION_MAX_PLAYERS: 8                         # Maximum connected players
SE_SESSION_MAX_FLOATING_OBJECTS: 100              # Floating object limit
SE_SESSION_MAX_BACKUP_SAVES: 5                    # Number of backup saves
SE_SESSION_MAX_GRID_SIZE: 0                       # Max blocks per grid (0 = unlimited)
SE_SESSION_MAX_BLOCKS_PER_PLAYER: 0              # Max blocks per player (0 = unlimited)
SE_SESSION_WORLD_SIZE_KM: 0                       # World size in km (0 = unlimited)
```

### Performance & Limits

```yaml
SE_SESSION_VIEW_DISTANCE: 7500                    # View distance in meters
SE_SESSION_SYNC_DISTANCE: 3000                    # Network sync distance
SE_SESSION_TOTAL_PCU: 200000                      # Total server PCU limit
SE_SESSION_PIRATE_PCU: 50000                      # PCU reserved for NPCs
SE_SESSION_GLOBAL_ENCOUNTER_PCU: 25000           # PCU for encounters
SE_SESSION_AUTO_SAVE_IN_MINUTES: 10              # Autosave interval
SE_SESSION_PHYSICS_ITERATIONS: 8                  # Physics quality (4-8)
SE_SESSION_ADAPTIVE_SIMULATION_QUALITY: true      # Dynamic quality adjustment
SE_SESSION_EXPERIMENTAL_MODE: true                # Enable experimental features
```

### Environment & Hostility

```yaml
SE_SESSION_ENVIRONMENT_HOSTILITY: NORMAL          # SAFE, NORMAL, CATACLYSM, CATACLYSMUNREAL
SE_SESSION_ENABLE_WOLFS: true                     # Enable wolf spawns
SE_SESSION_ENABLE_SPIDERS: true                   # Enable spider spawns
SE_SESSION_ENABLE_DRONES: true                    # Enable drone encounters
SE_SESSION_MAX_DRONES: 5                          # Maximum active drones
SE_SESSION_ENABLE_OXYGEN: true                    # Enable oxygen system
SE_SESSION_ENABLE_OXYGEN_PRESSURIZATION: true    # Enable pressurization
SE_SESSION_WEATHER_SYSTEM: true                   # Enable weather
SE_SESSION_WEATHER_LIGHTING_DAMAGE: false        # Lightning can damage grids
```

### Economy & NPCs

```yaml
SE_SESSION_ENABLE_ECONOMY: true                   # Enable economy system
SE_SESSION_ECONOMY_TICK_IN_SECONDS: 1200         # Economy update interval
SE_SESSION_CARGO_SHIPS_ENABLED: true             # Enable cargo ships
SE_SESSION_ENABLE_ENCOUNTERS: true                # Enable random encounters
SE_SESSION_ENABLE_BOUNTY_CONTRACTS: true         # Enable bounty contracts
SE_SESSION_TRADE_FACTIONS_COUNT: 10              # Number of trade factions
SE_SESSION_SCRAP_ENABLED: true                    # Enable scrap mechanic
```

### Multipliers & Speed

```yaml
SE_SESSION_INVENTORY_SIZE_MULTIPLIER: 3           # Inventory capacity multiplier
SE_SESSION_BLOCKS_INVENTORY_SIZE_MULTIPLIER: 1   # Block inventory multiplier
SE_SESSION_ASSEMBLER_SPEED_MULTIPLIER: 3         # Assembler speed
SE_SESSION_ASSEMBLER_EFFICIENCY_MULTIPLIER: 3    # Assembler efficiency
SE_SESSION_REFINERY_SPEED_MULTIPLIER: 3          # Refinery speed
SE_SESSION_WELDER_SPEED_MULTIPLIER: 2            # Welding speed
SE_SESSION_GRINDER_SPEED_MULTIPLIER: 2           # Grinding speed
SE_SESSION_HACK_SPEED_MULTIPLIER: 0.33           # Hacking speed
SE_SESSION_CHARACTER_SPEED_MULTIPLIER: 1         # Character movement speed
```

### Player Features & Tools

```yaml
SE_SESSION_ENABLE_SPECTATOR: false                # Allow spectator mode
SE_SESSION_ENABLE_INGAME_SCRIPTS: true           # Allow programmable blocks
SE_SESSION_ENABLE_SCRIPTER_ROLE: true            # Enable scripter role
SE_SESSION_ENABLE_COPY_PASTE: false              # Allow copy/paste
SE_SESSION_WEAPONS_ENABLED: true                  # Enable weapons
SE_SESSION_SHOW_PLAYER_NAMES_ON_HUD: true        # Show player names
SE_SESSION_ENABLE_3RD_PERSON_VIEW: true          # Allow 3rd person camera
SE_SESSION_ENABLE_JETPACK: true                   # Enable jetpack
SE_SESSION_ENABLE_VOXEL_HAND: true               # Enable voxel hand tool
SE_SESSION_ENABLE_TOOL_SHAKE: true                # Camera shake with tools
SE_SESSION_SPAWN_WITH_TOOLS: true                 # Players spawn with tools
```

### Respawn & Death

```yaml
SE_SESSION_ENABLE_RESPAWN_SHIPS: true            # Enable respawn ships
SE_SESSION_RESPAWN_SHIP_DELETE: false            # Delete old respawn ships
SE_SESSION_ENABLE_AUTO_RESPAWN: true             # Auto-respawn players
SE_SESSION_ENABLE_SPACE_SUIT_RESPAWN: true       # Can respawn in space suit
SE_SESSION_PERMANENT_DEATH: false                 # Permanent death mode
SE_SESSION_BACKPACK_DESPAWN_TIMER: 5             # Backpack despawn time (minutes)
```

### Building & Grids

```yaml
SE_SESSION_ENABLE_CONVERT_TO_STATION: true       # Allow ship->station conversion
SE_SESSION_STATION_VOXEL_SUPPORT: false          # Stations need voxel support
SE_SESSION_ENABLE_SUPERGRIDDING: false           # Allow supergridding exploit
SE_SESSION_ENABLE_SUBGRID_DAMAGE: false          # Subgrids take collision damage
SE_SESSION_ENABLE_TURRETS_FRIENDLY_FIRE: false   # Turrets hit friendlies
SE_SESSION_THRUSTER_DAMAGE: true                  # Thrusters damage blocks
SE_SESSION_DESTRUCTIBLE_BLOCKS: true              # Blocks can be destroyed
SE_SESSION_ENABLE_VOXEL_DESTRUCTION: true        # Voxels can be destroyed
SE_SESSION_AUTO_HEALING: true                     # Auto-repair blocks
```

### Trash Removal & Cleanup

```yaml
SE_SESSION_TRASH_REMOVAL_ENABLED: true           # Enable trash removal
SE_SESSION_STOP_GRIDS_PERIOD_MIN: 15             # Time before grid marked as trash
SE_SESSION_TRASH_FLAGS_VALUE: 1562                # Trash criteria flags
SE_SESSION_BLOCK_COUNT_THRESHOLD: 20              # Min blocks to be considered
SE_SESSION_PLAYER_DISTANCE_THRESHOLD: 500        # Distance from players (meters)
SE_SESSION_PLAYER_CHARACTER_REMOVAL_THRESHOLD: 15 # Remove dead characters after (min)
SE_SESSION_VOXEL_TRASH_REMOVAL_ENABLED: false    # Remove voxel changes
SE_SESSION_ENABLE_CONTAINER_DROPS: true          # Enable container drops
SE_SESSION_MAX_CARGO_BAGS: 100                    # Max cargo bag entities
```

### Advanced Settings

```yaml
SE_SESSION_ENABLE_GOOD_BOT_HINTS: false          # Enable tutorial hints
SE_SESSION_ENABLE_RESEARCH: true                  # Enable research system
SE_SESSION_ENABLE_RECOIL: true                    # Weapon recoil
SE_SESSION_ENABLE_SUN_ROTATION: true             # Day/night cycle
SE_SESSION_SUN_ROTATION_INTERVAL_MINUTES: 120    # Day length in minutes
SE_SESSION_ENABLE_SHARE_INERTIA_TENSOR: false    # Advanced physics
SE_SESSION_ENABLE_SELECTIVE_PHYSICS_UPDATES: false # Optimization feature
SE_SESSION_PROCEDURAL_DENSITY: 0.35              # Asteroid density
SE_SESSION_PROCEDURAL_SEED: 0                     # World seed (0 = random)
SE_SESSION_MAX_PLANETS: 99                        # Maximum planets
SE_SESSION_PREDEFINED_ASTEROIDS: true            # Use predefined asteroids
``` AI & NPCs

```yaml
# Cargo ships
SE_CARGO_SHIPS_ENABLED: true

# Drones
SE_ENABLE_DRONES: true

# Spiders
SE_ENABLE_SPIDERS: true

# Wolves
SE_ENABLE_WOLVES: true
```

## Performance Tuning

### For Weak CPUs (like yours)

```yaml
# Minimal settings
SE_MAX_PLAYERS: 4
## Performance Tuning

### For Weak CPUs

Optimize for servers with limited CPU resources (2-4 cores):

```yaml
# Root settings
SE_PAUSE_GAME_WHEN_EMPTY: true

# Session settings
SE_SESSION_MAX_PLAYERS: 4
SE_SESSION_VIEW_DISTANCE: 5000
SE_SESSION_SYNC_DISTANCE: 3000
SE_SESSION_MAX_FLOATING_OBJECTS: 32
SE_SESSION_PROCEDURAL_DENSITY: 0.25
SE_SESSION_PHYSICS_ITERATIONS: 4
SE_SESSION_ADAPTIVE_SIMULATION_QUALITY: true

# Torch plugins (critical for performance)
INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 6000
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```

### For Medium Servers

Balanced settings for 4-8 core CPUs:

```yaml
SE_SESSION_MAX_PLAYERS: 16
SE_SESSION_VIEW_DISTANCE: 7500
SE_SESSION_SYNC_DISTANCE: 5000
SE_SESSION_MAX_FLOATING_OBJECTS: 100
SE_SESSION_PHYSICS_ITERATIONS: 8

INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 8000
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```

### For High-Performance Servers

Settings for dedicated servers with 8+ cores:

```yaml
SE_SESSION_MAX_PLAYERS: 32
SE_SESSION_VIEW_DISTANCE: 15000
SE_SESSION_SYNC_DISTANCE: 10000
SE_SESSION_MAX_FLOATING_OBJECTS: 200
SE_SESSION_PHYSICS_ITERATIONS: 8

INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 15000
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```TALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 8000  # Distance in meters before grids pause
```

**Benefits:**
- 50-90% performance improvement
- Pauses grids when no players nearby

**Side Effects:**
- Long-distance drones may pause
- Laser antennas may disconnect at distance

### Performance Improvements Plugin

```yaml
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```
## Torch Plugins

The Torch server variant supports performance and admin plugins. These are configured via environment variables (not `SE_` prefixed).

### Concealment Plugin

Dramatically improves performance by pausing grids when no players are nearby.

```yaml
INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 8000  # Distance in meters before grids pause
```

**Performance Impact:**
- 50-90% reduction in simulation load
- Allows weak CPUs to host larger worlds
- Grids resume instantly when players approach

**Trade-offs:**
- Long-distance drones/automation may pause
- Laser antennas may disconnect beyond concealment distance
- Timer blocks on concealed grids don't execute

**Recommended Distances:**
- Small servers (2-4 players): 6000-8000m
- Medium servers (8-16 players): 8000-12000m
- Large servers (16+ players): 12000-15000m

### Performance Improvements Plugin

Fixes various game inefficiencies and reduces memory pressure.

```yaml
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```

**Improvements:**
- Reduces GC (garbage collection) pressure
- Optimizes safe zone checks (2-second cache)
- Patches inefficient game code paths
- Generally improves simulation speed

**Compatibility:** Safe to use with all servers, no trade-offs.

### Essentials Plugin
## Example Configurations

### Example 1: Small Private Co-op (2-4 Players)

```yaml
# Root-level
SE_SERVER_NAME: "Friends Only - Earth Survival"
SE_WORLD_NAME: "Earth Planet"
SE_PAUSE_GAME_WHEN_EMPTY: true
SE_SERVER_PORT: 27016
SE_STEAM_PORT: 8766
SE_PREMADE_CHECKPOINT_PATH: "Content/CustomWorlds/Star System"

# Session settings
SE_SESSION_GAME_MODE: Survival
SE_SESSION_ONLINE_MODE: FRIENDS
SE_SESSION_MAX_PLAYERS: 4
SE_SESSION_VIEW_DISTANCE: 7500
SE_SESSION_SYNC_DISTANCE: 3000
SE_SESSION_INVENTORY_SIZE_MULTIPLIER: 3
SE_SESSION_ASSEMBLER_SPEED_MULTIPLIER: 3
SE_SESSION_REFINERY_SPEED_MULTIPLIER: 3
SE_SESSION_ENABLE_INGAME_SCRIPTS: true
SE_SESSION_ENVIRONMENT_HOSTILITY: NORMAL

# Performance
INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 10000
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```

### Example 2: Public PvP Server (8-16 Players)

```yaml
# Root-level
SE_SERVER_NAME: "Public PvP - Star System"
SE_PAUSE_GAME_WHEN_EMPTY: false
SE_ADMINISTRATORS: "76561198012345678"
SE_PREMADE_CHECKPOINT_PATH: "Content/CustomWorlds/Star System"

# Session settings
SE_SESSION_GAME_MODE: Survival
SE_SESSION_ONLINE_MODE: PUBLIC
SE_SESSION_MAX_PLAYERS: 16
SE_SESSION_VIEW_DISTANCE: 10000
SE_SESSION_SYNC_DISTANCE: 5000
SE_SESSION_TOTAL_PCU: 300000
SE_SESSION_PIRATE_PCU: 50000
SE_SESSION_WEAPONS_ENABLED: true
SE_SESSION_ENABLE_TURRETS_FRIENDLY_FIRE: false
SE_SESSION_CARGO_SHIPS_ENABLED: true
SE_SESSION_ENABLE_ENCOUNTERS: true
SE_SESSION_ENABLE_ECONOMY: true
SE_SESSION_ENVIRONMENT_HOSTILITY: NORMAL

# Performance
INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 12000
INSTALL_PERFORMANCE_IMPROVEMENTS: true
INSTALL_ESSENTIALS: true
```

### Example 3: Large Community Server (High Performance)

```yaml
# Root-level
SE_SERVER_NAME: "Community Mega-Server"
SE_PAUSE_GAME_WHEN_EMPTY: false
SE_ADMINISTRATORS: "76561198012345678,76561198087654321"
SE_PREMADE_CHECKPOINT_PATH: "Content/CustomWorlds/Star System"

# Session settings
SE_SESSION_GAME_MODE: Survival
SE_SESSION_ONLINE_MODE: PUBLIC
SE_SESSION_MAX_PLAYERS: 32
SE_SESSION_VIEW_DISTANCE: 15000
SE_SESSION_SYNC_DISTANCE: 10000
SE_SESSION_TOTAL_PCU: 500000
SE_SESSION_PIRATE_PCU: 100000
SE_SESSION_MAX_FLOATING_OBJECTS: 200
SE_SESSION_PHYSICS_ITERATIONS: 8
SE_SESSION_ADAPTIVE_SIMULATION_QUALITY: true
SE_SESSION_ENABLE_ECONOMY: true
SE_SESSION_CARGO_SHIPS_ENABLED: true
SE_SESSION_ENABLE_ENCOUNTERS: true
SE_SESSION_EXPERIMENTAL_MODE: true

# Performance
INSTALL_CONCEALMENT: true
CONCEALMENT_DISTANCE: 15000
INSTALL_PERFORMANCE_IMPROVEMENTS: true
INSTALL_ESSENTIALS: true
```

### Example 4: Creative Build Server

```yaml
# Root-level
SE_SERVER_NAME: "Creative Building"
SE_PAUSE_GAME_WHEN_EMPTY: true

# Session settings
SE_SESSION_GAME_MODE: Creative
SE_SESSION_ONLINE_MODE: FRIENDS
SE_SESSION_MAX_PLAYERS: 8
SE_SESSION_ENABLE_COPY_PASTE: true
SE_SESSION_ENABLE_SPECTATOR: true
SE_SESSION_WEAPONS_ENABLED: false
SE_SESSION_ENVIRONMENT_HOSTILITY: SAFE
SE_SESSION_ENABLE_WOLFS: false
SE_SESSION_ENABLE_SPIDERS: false
SE_SESSION_CARGO_SHIPS_ENABLED: false
SE_SESSION_TOTAL_PCU: 1000000

# Performance
INSTALL_CONCEALMENT: false
INSTALL_PERFORMANCE_IMPROVEMENTS: true
```

## Important Notes

### Configuration Priority

1. **GUI-generated XML** is the source of truth
2. **Environment variables** override XML values on container start
3. Use the Space Engineers Dedicated Server GUI to create your base configuration
4. Use environment variables for settings you want to change frequently

### Finding Steam64 IDs

Get Steam64 IDs at: https://steamid.io/

### Debugging Configuration

Enable verbose output to see which settings are applied:

```yaml
SHOW_CONFIG_OPTIONS: true
```

This will display all available configuration options and their current values during container startup.

### XML Structure Reference

The configuration file has this structure:
```xml
<MyConfigDedicated>
  <!-- Root-level settings (SE_*) -->
  <ServerName>...</ServerName>
  <WorldName>...</WorldName>
  <IP>...</IP>
  
  <!-- Session settings (SE_SESSION_*) -->
  <SessionSettings>
    <GameMode>...</GameMode>
    <MaxPlayers>...</MaxPlayers>
    <ViewDistance>...</ViewDistance>
    ...
  </SessionSettings>
</MyConfigDedicated>
```

Environment variables automatically map to these XML paths using the config-helper.sh script.
