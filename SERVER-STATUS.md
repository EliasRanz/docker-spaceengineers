# Space Engineers Server Status Guide

## How to Check If Your Server is Running

### 1. Check Docker Container Status

```bash
docker ps | grep se-server
```

**Expected output when running:**
```
CONTAINER ID   IMAGE                                                    STATUS
13f77f728a36   ghcr.io/eliasranz/docker-spaceengineers:master-torch   Up 3 minutes
```

If the container is not in the list, check stopped containers:
```bash
docker ps -a | grep se-server
```

### 2. Check Torch Server Logs

```bash
docker logs -f se-server
```

**Signs that Torch is starting successfully:**
```
-------------------------------VERIFY SE INSTALLATION------------------------
✓ DedicatedServer64 directory exists
✓ Symlink created successfully
✓ Via GAME_DIR: /appdata/space-engineers/SpaceEngineersDedicated/DedicatedServer64/steam_api64.dll
✓ Via symlink: /appdata/space-engineers/instances/SE/DedicatedServer64/steam_api64.dll

-------------------------------START TORCH SERVER---------------------------
[INFO]   Initializer: Loading config Torch.cfg
[INFO]   PatchManager: Patching begins...
[INFO]   PatchManager: Patched 13/13. (100%)
[INFO]   PatchManager: Patching done
```

**Signs that the game world is loading:**
```
[INFO]   Keen: Loading world
[INFO]   Keen: MySession.Init
```

**Signs that the server is fully running:**
```
[INFO]   Keen: Server ready...
[INFO]   Keen: Listening on port 27016
```

### 3. Check if Space Engineers is Responding

From **inside the container**:
```bash
docker exec -it se-server bash
netstat -tlnp | grep 27016
```

**Expected output:**
```
tcp        0      0 0.0.0.0:27016           0.0.0.0:*               LISTEN      -
udp        0      0 0.0.0.0:27016           0.0.0.0:*                           -
```

From **your host machine**:
```bash
netstat -an | grep 27016
```

or on Linux/Mac:
```bash
ss -tuln | grep 27016
```

### 4. Check Game Server List

1. Open Space Engineers
2. Go to **Join Game**
3. Search for your server name (configured as `SE_SERVER_NAME` in docker-compose.yml)
4. You should see "EliasRanz Space Engineers Server" in the list

### 5. Check Server Accessibility (External)

From another computer on your network or the internet:
```bash
telnet YOUR_SERVER_IP 27016
```

or using `nc`:
```bash
nc -zv YOUR_SERVER_IP 27016
```

**Expected output:**
```
Connection to YOUR_SERVER_IP 27016 port [tcp/*] succeeded!
```

## Common Issues and What They Mean

### Container Exits Immediately
**Check logs:** `docker logs se-server`

**Common causes:**
- Configuration error in docker-compose.yml
- Volume mount issues
- Port already in use

### "Testing connection to API" and then silence
```
[WARN] PluginQuery: Testing connection to API
```

**This is NORMAL!** The TorchAPI plugin repository is currently experiencing 404 errors. The server will continue to start despite this warning. It just means auto-plugin downloads are not working.

### "Error loading world" or crash during load
**Possible causes:**
- Corrupted world save
- Insufficient memory (SE needs at least 8GB RAM)
- Incompatible mods
- Permission issues on volume mounts

### High CPU but no progress
**Check for:**
- Large world loading (can take 5-15 minutes for big worlds)
- Many mods compiling (first start can be slow)
- Check logs with: `docker logs -f se-server | grep -i error`

## Performance Indicators

### Good Performance Signs
```
[INFO]   Keen: Simulation speed: 1.00
[INFO]   Server speed: Normal (1.00)
[INFO]   Used PCU: 25000 / 200000
```

### Poor Performance Signs
```
[WARN]   Keen: Simulation speed: 0.85  # Below 0.9 = lag
[ERROR]  Thread pool exhausted
[WARN]   High memory usage
```

## Torch-Specific Status Checks

### Check Torch is Running (from inside container)
```bash
docker exec se-server ps aux | grep Torch
```

**Expected:**
```
root         PID  ... wine Torch.Server.exe -noupdate -autostart
```

### Check Torch Configuration
```bash
docker exec se-server cat /appdata/space-engineers/instances/SE/Torch.cfg
```

Should show InstallPath pointing to: `/appdata/space-engineers/SpaceEngineersDedicated`

## Network Troubleshooting

### Verify Port Forwarding
If players can't connect from outside your network:

1. **Check router port forwarding:**
   - Forward UDP port 27016 to your server's local IP
   - Forward TCP port 18080 (for Torch remote API)

2. **Check firewall:**
   ```bash
   # On host machine (Proxmox/Linux)
   sudo iptables -L -n | grep 27016
   ```

3. **Test from external service:**
   - Use https://www.yougetsignal.com/tools/open-ports/
   - Enter your public IP and port 27016

### DNS Resolution
If using a domain name (`SE_IP=se.eliasranz.com`):
```bash
nslookup se.eliasranz.com
```

Should return your public IP address.

## Plugin Installation

### Automated Installation (Performance Improvements)

The **Performance Improvements** plugin is automatically downloaded from GitHub releases when:
- `INSTALL_PERFORMANCE_IMPROVEMENTS=true` in docker-compose.yml (default)
- Plugin is not already installed

No manual steps needed! Just start the container and check logs:
```bash
docker logs -f se-server | grep "Performance Improvements"
```

### Manual Installation (Other Plugins)

Since TorchAPI download URLs are currently broken (404 errors), other plugins must be installed manually:

#### Concealment Plugin (Performance Critical)
1. Visit: https://torchapi.com/plugins/view/17f44521-b77a-4e85-810f-ee73311cf75d
2. Download the ZIP when TorchAPI is back online
3. Extract to: `/tank/docker/space-engineers/instances/SE/Plugins/`
4. Restart container: `docker restart se-server`

**Alternative:** Check the plugin's GitHub page or SE Mods Discord for direct downloads

#### Other Plugins
1. Visit https://torchapi.com/plugins
2. Find the plugin page
3. Look for GitHub links in the description
4. Download from GitHub releases or TorchAPI (when available)
5. Extract to the Plugins folder: `/tank/docker/space-engineers/instances/SE/Plugins/`
6. Restart the container

## Monitoring Tools

### Real-time Log Monitoring
```bash
# Follow logs with timestamps
docker logs -tf se-server

# Filter for errors only
docker logs -f se-server 2>&1 | grep -i error

# Filter for player joins
docker logs -f se-server 2>&1 | grep -i "player\|joined\|left"
```

### Resource Usage
```bash
# CPU and memory usage
docker stats se-server

# Detailed container info
docker inspect se-server
```

### Check Volume Mounts
```bash
# Verify data is being written
ls -lah /tank/docker/space-engineers/dedicated/
ls -lah /tank/docker/space-engineers/instances/SE/
```

## Success Indicators Summary

✅ **Server is fully running when you see:**
1. Container status: "Up X minutes" (not restarting)
2. Logs show: "Server ready..." or "Listening on port"
3. Port 27016 is listening (check with `netstat`)
4. Server appears in game's server list
5. Players can connect and join the world
6. Simulation speed stable around 1.0

⚠️ **Server is starting but not ready:**
- Logs show "Loading world" or "Compiling mods"
- High CPU usage but no errors
- Be patient - large worlds take time

❌ **Server has issues:**
- Container keeps restarting
- Logs show errors or exceptions
- Port 27016 not listening
- Simulation speed consistently below 0.8
