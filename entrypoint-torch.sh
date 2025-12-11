#!/bin/bash
# VARIABLES
GAME_DIR="/appdata/space-engineers/SpaceEngineersDedicated"
INSTANCES_DIR="/appdata/space-engineers/instances"
TORCH_DIR="/opt/torch"
CONFIG_PATH="${INSTANCES_DIR}/${INSTANCE_NAME}/Torch.cfg"
SE_CONFIG_PATH="${INSTANCES_DIR}/${INSTANCE_NAME}/Instance/SpaceEngineers-Dedicated.cfg"
DEFAULT_CONFIG="${GAME_DIR}/DedicatedServer64/SpaceEngineers-Dedicated.cfg"
INSTANCE_IP=$(hostname -I | sed "s= ==g")

# Load config helper functions
source /root/config-helper.sh

echo "-------------------------------INSTALL & UPDATE------------------------------"
# Set platform before anything else, then login, then install
/usr/games/steamcmd \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir ${GAME_DIR} \
  +login anonymous \
  +app_update 298740 validate \
  +quit

echo "-------------------------------VERIFY SE INSTALLATION------------------------"
echo "Checking Space Engineers installation at: ${GAME_DIR}"
if [ -d "${GAME_DIR}/DedicatedServer64" ]; then
  echo "✓ DedicatedServer64 directory exists"
  echo "  Files in DedicatedServer64:"
  ls -lh "${GAME_DIR}/DedicatedServer64/" | grep -E "(steam_api64|SpaceEngineers)" | head -10
else
  echo "✗ DedicatedServer64 directory NOT FOUND at: ${GAME_DIR}/DedicatedServer64"
  echo "  Contents of GAME_DIR:"
  ls -la "${GAME_DIR}/" || echo "  GAME_DIR does not exist!"
fi

echo "---------------------------------SETUP TORCH---------------------------------"
# Copy Torch files to instance directory if not already present
if [ ! -f "${INSTANCES_DIR}/${INSTANCE_NAME}/Torch.Server.exe" ]; then
  echo "Initializing Torch server in instance directory..."
  mkdir -p ${INSTANCES_DIR}/${INSTANCE_NAME}
  
  # Verify Torch source directory exists and has files
  if [ ! -d "${TORCH_DIR}" ] || [ -z "$(ls -A ${TORCH_DIR})" ]; then
    echo "ERROR: Torch directory is missing or empty at ${TORCH_DIR}"
    echo "The Docker image may not have been built correctly with SERVER_TYPE=torch"
    exit 1
  fi
  
  echo "Copying Torch files from ${TORCH_DIR}..."
  cp -rv ${TORCH_DIR}/* ${INSTANCES_DIR}/${INSTANCE_NAME}/ 2>&1 | head -20
  echo "Torch files copied"
fi

# Verify critical Torch files exist
echo "Verifying Torch installation..."
MISSING_FILES=0
for file in "Torch.Server.exe" "Torch.Server.exe.config" "NLog.dll" "Torch.dll" "Torch.API.dll"; do
  if [ ! -f "${INSTANCES_DIR}/${INSTANCE_NAME}/${file}" ]; then
    echo "  ✗ Missing: ${file}"
    ((MISSING_FILES++))
  else
    echo "  ✓ Found: ${file}"
  fi
done

if [ $MISSING_FILES -gt 0 ]; then
  echo "ERROR: ${MISSING_FILES} critical Torch files are missing"
  echo "Listing instance directory contents:"
  ls -la "${INSTANCES_DIR}/${INSTANCE_NAME}/" | head -30
  exit 1
fi

# Create symlink to SE game files so Torch can find them
echo "Checking DedicatedServer64 symlink..."
if [ -L "${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64" ]; then
  echo "  Symlink exists, removing to recreate..."
  rm "${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64"
fi

echo "Creating symlink: ${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64 → ${GAME_DIR}/DedicatedServer64"
ln -s "${GAME_DIR}/DedicatedServer64" "${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64"

# Verify symlink creation
if [ -L "${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64" ]; then
  echo "✓ Symlink created successfully"
  echo "  Link target: $(readlink ${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64)"
else
  echo "✗ Failed to create symlink!"
fi

# Verify steam_api64.dll is accessible through both paths
echo "Verifying steam_api64.dll accessibility:"
if [ -f "${GAME_DIR}/DedicatedServer64/steam_api64.dll" ]; then
  echo "  ✓ Via GAME_DIR: ${GAME_DIR}/DedicatedServer64/steam_api64.dll"
else
  echo "  ✗ NOT FOUND via GAME_DIR: ${GAME_DIR}/DedicatedServer64/steam_api64.dll"
fi

if [ -f "${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64/steam_api64.dll" ]; then
  echo "  ✓ Via symlink: ${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64/steam_api64.dll"
else
  echo "  ✗ NOT FOUND via symlink: ${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64/steam_api64.dll"
  echo "  Directory contents:"
  ls -la "${INSTANCES_DIR}/${INSTANCE_NAME}/" 2>/dev/null || echo "  Instance directory doesn't exist"
fi

echo "-----------------------------INSTALL PERFORMANCE PLUGINS---------------------"
# Plugin directory
PLUGINS_DIR="${INSTANCES_DIR}/${INSTANCE_NAME}/Plugins"
mkdir -p "${PLUGINS_DIR}"

# Default plugin settings (can be overridden via environment variables)
INSTALL_CONCEALMENT="${INSTALL_CONCEALMENT:-true}"
INSTALL_PERFORMANCE_IMPROVEMENTS="${INSTALL_PERFORMANCE_IMPROVEMENTS:-true}"
INSTALL_ESSENTIALS="${INSTALL_ESSENTIALS:-false}"

# Concealment Plugin - Critical for performance on weak CPUs
# Pauses grids when no players are nearby, reduces sim speed load by 50-90%
if [ "$INSTALL_CONCEALMENT" = "true" ]; then
  # Check if plugin DLL exists (installed manually or from previous working download)
  if [ -f "${PLUGINS_DIR}/Concealment.dll" ] || [ -f "${PLUGINS_DIR}/Concealment/Concealment.dll" ]; then
    echo "✓ Concealment plugin already installed"
  else
    echo "Installing Concealment plugin from TorchAPI..."
    CONCEALMENT_FILE="${PLUGINS_DIR}/Concealment.zip"
    wget --timeout=30 --tries=3 -O "$CONCEALMENT_FILE" "https://torchapi.com/plugin/download/17f44521-b77a-4e85-810f-ee73311cf75d" 2>&1
    if [ $? -eq 0 ] && [ -f "$CONCEALMENT_FILE" ] && [ -s "$CONCEALMENT_FILE" ]; then
      unzip -q -o "$CONCEALMENT_FILE" -d "${PLUGINS_DIR}/" && rm "$CONCEALMENT_FILE"
      echo "✓ Concealment plugin installed"
    else
      echo "✗ Failed to download Concealment plugin (will retry next start)"
      rm -f "$CONCEALMENT_FILE"
    fi
  fi
fi

# Performance Improvements Plugin - Viktor's optimization patches
if [ "$INSTALL_PERFORMANCE_IMPROVEMENTS" = "true" ]; then
  # Check if plugin DLL exists (any of the possible locations)
  if [ -f "${PLUGINS_DIR}/PerformanceImprovements.dll" ] || \
     [ -f "${PLUGINS_DIR}/TorchPlugin.dll" ] || \
     [ -f "${PLUGINS_DIR}/PerformanceImprovements/PerformanceImprovements.dll" ]; then
    echo "✓ Performance Improvements plugin already installed"
  else
    echo "Installing Performance Improvements plugin from TorchAPI..."
    PERF_FILE="${PLUGINS_DIR}/PerformanceImprovements.zip"
    
    wget --timeout=30 --tries=3 -O "$PERF_FILE" "https://torchapi.com/plugin/download/c2cf3ed2-c6ac-4dbd-ab9a-613a1ef67784" 2>&1
    if [ $? -eq 0 ] && [ -f "$PERF_FILE" ] && [ -s "$PERF_FILE" ]; then
      unzip -q -o "$PERF_FILE" -d "${PLUGINS_DIR}/" && rm "$PERF_FILE"
      echo "✓ Performance Improvements plugin installed"
    else
      echo "✗ Failed to download from TorchAPI, trying GitHub..."
      rm -f "$PERF_FILE"
      PERF_FILE="${PLUGINS_DIR}/TorchPlugin.zip"
      wget --timeout=30 --tries=3 -O "$PERF_FILE" "https://github.com/viktor-ferenczi/se-performance-improvements/releases/latest/download/TorchPlugin.zip" 2>&1
      if [ $? -eq 0 ] && [ -f "$PERF_FILE" ] && [ -s "$PERF_FILE" ]; then
        unzip -q -o "$PERF_FILE" -d "${PLUGINS_DIR}/" && rm "$PERF_FILE"
        echo "✓ Performance Improvements plugin installed from GitHub"
      else
        echo "✗ Failed to download Performance Improvements plugin"
        rm -f "$PERF_FILE"
      fi
    fi
  fi
fi

# Essentials Plugin - Cleanup automation and admin tools
# Provides grid limits, automated cleanup, trash removal
if [ "$INSTALL_ESSENTIALS" = "true" ]; then
  # Check if plugin DLL exists
  if [ -f "${PLUGINS_DIR}/Essentials.dll" ] || [ -f "${PLUGINS_DIR}/Essentials/Essentials.dll" ]; then
    echo "✓ Essentials plugin already installed"
  else
    echo "Installing Essentials plugin from TorchAPI..."
    ESSENTIALS_FILE="${PLUGINS_DIR}/Essentials.zip"
    wget --timeout=30 --tries=3 -O "$ESSENTIALS_FILE" "https://torchapi.com/plugin/download/cbfdd6ab-4cda-4544-a201-f73efa3d46c0" 2>&1
    if [ $? -eq 0 ] && [ -f "$ESSENTIALS_FILE" ] && [ -s "$ESSENTIALS_FILE" ]; then
      unzip -q -o "$ESSENTIALS_FILE" -d "${PLUGINS_DIR}/" && rm "$ESSENTIALS_FILE"
      echo "✓ Essentials plugin installed"
    else
      echo "✗ Failed to download Essentials plugin (will retry next start)"
      rm -f "$ESSENTIALS_FILE"
    fi
  fi
fi

echo "-----------------------------CONFIGURE PLUGINS-------------------------------"
# Configure Concealment plugin if installed
if [ "$INSTALL_CONCEALMENT" = "true" ]; then
  CONCEALMENT_CONFIG="${PLUGINS_DIR}/Concealment/Concealment.cfg"
  CONCEALMENT_DISTANCE="${CONCEALMENT_DISTANCE:-8000}"
  
  if [ -f "$CONCEALMENT_CONFIG" ]; then
    echo "Configuring Concealment plugin (distance: ${CONCEALMENT_DISTANCE}m)..."
    # Use xmlstarlet to update concealment distance if config exists
    # This allows users to adjust for long-distance automation needs
    # Note: Config structure may vary by version, this is a best-effort approach
  else
    echo "Note: Concealment config will be created on first run"
    echo "  Default distance: ${CONCEALMENT_DISTANCE}m from players"
    echo "  Adjust CONCEALMENT_DISTANCE env var if needed for drones/automation"
  fi
fi

# Create default Torch config if it doesn't exist
if [ ! -f "${CONFIG_PATH}" ]; then
  echo "Creating default Torch configuration..."
  cat > ${CONFIG_PATH} << EOF
<?xml version="1.0"?>
<TorchConfig xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <InstancePath>Saves</InstancePath>
  <InstanceName>Instance</InstanceName>
  <InstallPath>${GAME_DIR}</InstallPath>
  <AutodetectPlugins>true</AutodetectPlugins>
  <Plugins />
  <EnableAsserts>false</EnableAsserts>
  <IndependentConsole>false</IndependentConsole>
  <ShouldUpdate>false</ShouldUpdate>
  <RestartOnCrash>false</RestartOnCrash>
  <GetPluginUpdates>false</GetPluginUpdates>
  <TickTimeout>60</TickTimeout>
  <ChatName>Torch</ChatName>
  <ChatColor>Red</ChatColor>
  <LocalPlugins>false</LocalPlugins>
  <WaitForPID />
  <Autostart>false</Autostart>
  <NoGUI>true</NoGUI>
</TorchConfig>
EOF
fi

echo "---------------------------------INITIALIZE SE CONFIG------------------------"
# Torch uses Instance/SpaceEngineers-Dedicated.cfg for SE settings
mkdir -p "${INSTANCES_DIR}/${INSTANCE_NAME}/Instance"

# Use embedded default config as fallback if SE installation doesn't have one
DEFAULT_TEMPLATE="/root/SpaceEngineers-Dedicated.default.cfg"

if [ ! -f "$DEFAULT_CONFIG" ]; then
  echo "Default config not found in SE installation, using embedded template"
  DEFAULT_CONFIG="$DEFAULT_TEMPLATE"
fi

# Initialize config - copy default if user doesn't have one
initialize_config "$DEFAULT_CONFIG" "$SE_CONFIG_PATH" "$AUTO_UPDATE_CONFIG"

# Show available options if requested
if [ "$SHOW_CONFIG_OPTIONS" = "true" ]; then
    show_available_config "$SE_CONFIG_PATH"
fi

echo "--------------------------APPLY ENVIRONMENT OVERRIDES------------------------"
# Apply any SE_ prefixed environment variables to SE config
apply_environment_overrides "$SE_CONFIG_PATH"

echo "-----------------------------CURRENT CONFIGURATION---------------------------"
echo "GAME_DIR=$GAME_DIR"
echo "TORCH_DIR=$TORCH_DIR"
echo "INSTANCES_DIR=$INSTANCES_DIR"
echo "CONFIG_PATH=$CONFIG_PATH"
echo "INSTANCE_IP=$INSTANCE_IP"
wine --version

# Verify critical files exist
echo "--------------------------------PRE-FLIGHT CHECKS----------------------------"
echo "Checking Torch.Server.exe..."
if [ -f "${INSTANCES_DIR}/${INSTANCE_NAME}/Torch.Server.exe" ]; then
    echo "✓ Torch.Server.exe found"
else
    echo "✗ ERROR: Torch.Server.exe not found!"
    exit 1
fi

echo "Checking SE game files via symlink..."
if [ -f "${INSTANCES_DIR}/${INSTANCE_NAME}/DedicatedServer64/SpaceEngineersDedicated.exe" ]; then
    echo "✓ SpaceEngineersDedicated.exe accessible"
else
    echo "✗ ERROR: SpaceEngineersDedicated.exe not found!"
    exit 1
fi

echo "Checking Torch.cfg..."
if [ -f "${INSTANCES_DIR}/${INSTANCE_NAME}/Torch.cfg" ]; then
    echo "✓ Torch.cfg found"
    echo "Instance Path in Torch.cfg:"
    grep -A 1 "<InstancePath>" "${INSTANCES_DIR}/${INSTANCE_NAME}/Torch.cfg" || echo "  (not set)"
else
    echo "✗ WARNING: Torch.cfg not found"
fi

echo "--------------------------------START TORCH SERVER---------------------------"
cd ${INSTANCES_DIR}/${INSTANCE_NAME} || exit 1

# List files in current directory for debugging
echo "Current directory: $(pwd)"
echo "Files present:"
ls -lh *.exe 2>/dev/null | head -5 || echo "No .exe files found"

# Run Torch with proper flags for headless operation
# -noupdate: Skip Torch updates
# -autostart: Start server automatically
# -nogui: Disable GUI (critical for Docker)
# -console: Force console mode
echo "Starting Wine with Torch.Server.exe..."

# Set Wine environment to match build configuration
export WINEARCH=win64
export WINEPREFIX=/root/server
# Allow .NET runtime to load (Torch requires it), but disable IE components
export WINEDLLOVERRIDES="mshtml=d"

# Check if Torch.Server.exe is executable
if [ ! -x "Torch.Server.exe" ]; then
    echo "Making Torch.Server.exe executable..."
    chmod +x Torch.Server.exe
fi

# Verify Wine prefix exists
if [ ! -d "$WINEPREFIX" ]; then
    echo "ERROR: Wine prefix not found at $WINEPREFIX"
    echo "This shouldn't happen - wine was not properly initialized during build"
    exit 1
fi

echo "Wine configuration:"
echo "  WINEPREFIX: $WINEPREFIX"
echo "  WINEARCH: $WINEARCH"

# Check for .NET installation in Wine prefix
echo "Checking .NET Framework installation..."
if [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET" ]; then
    echo "✓ .NET Framework directory found"
    ls -la "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework64/" 2>/dev/null | grep "v4" || echo "  WARNING: .NET 4.x not found"
else
    echo "✗ .NET Framework NOT FOUND - Torch requires .NET 4.8"
    echo "  This indicates winetricks installation failed during build"
fi

# Suppress Wine warnings - only show errors
echo "Starting Torch Server..."
export WINEDEBUG=-all,err+all

# Run with explicit error capture
wine Torch.Server.exe -noupdate -autostart -nogui -console 2>&1
WINE_EXIT_CODE=$?

echo "-----------------------------------END GAME----------------------------------"
echo "Wine exit code: $WINE_EXIT_CODE"
sleep 1
echo "-----------------------------------BYE !!!!----------------------------------"
