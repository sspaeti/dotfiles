# Windows VM Integration

A seamless Windows 11 VM setup that integrates with your Linux desktop environment via Docker and RDP.

> **First-time startup will take significantly longer** as the container needs to:
> - Download the Windows 11 ISO (~5GB)
> - Install and configure Windows
> - This can take 30-60 minutes depending on your internet connection

After the initial setup, subsequent launches will be much faster (2-3 minutes). See [dockur/windows](https://github.com/dockur/windows) for more details on the setup process.

## Files

- `docker-compose.yml` - Docker Compose configuration for Windows 11 VM
- `start-windows.sh` - Automated launch script with lifecycle management
- `../../../linux_applications/.local/share/applications/windows-vm.desktop` - Desktop entry for application launcher

## How It Works

### Launch Process
1. **Desktop Integration**: Appears as "Windows VM" in your application launcher
2. **Container Management**: Starts Docker container with Windows 11
3. **Health Monitoring**: Waits for container to be running and web interface to respond
4. **RDP Connection**: Automatically opens RDP connection (1920x1200 resolution)
5. **Auto-Cleanup**: When you close RDP, the Windows VM automatically shuts down

### Configuration
- **OS**: Windows 11
- **Resources**: 8GB RAM, 4 CPU cores
- **Acceleration**: KVM support for better performance
- **Storage**: Persistent storage mounted to `~/windows`
- **Network**: 
  - RDP: `127.0.0.1:3389`
  - Web Interface: `http://127.0.0.1:8006`

### Key Features
- **Smart Waiting**: Monitors Docker container health and web interface before launching RDP
- **Signal Handling**: Properly handles interruptions with cleanup
- **UWSM Integration**: Runs as a managed Hyprland application
- **One-Click Experience**: Single click to boot Windows and connect
- **Automatic Shutdown**: VM stops when RDP session ends

## Usage

### Via Desktop Launcher
Simply click "Windows VM" from your application launcher.

### Via Command Line
```bash
./start-windows.sh
```

### Manual Docker Management
```bash
# Start container
docker-compose up -d

# Stop container  
docker-compose down

# View logs
docker-compose logs -f
```

## Requirements

- Docker and Docker Compose
- `rdesktop` for RDP client
- `netcat` (`nc`) for port checking
- `curl` for web interface health checks
- KVM support for hardware acceleration

Thanks to https://github.com/dockur/windows for the windows docker image, that does all the hard work.

## Troubleshooting

- **Container starts but RDP fails**: Check if Windows is fully booted via web interface at http://127.0.0.1:8006
- **Slow startup**: Windows VM needs 2-3 minutes for full boot, script waits automatically
- **Connection refused**: Ensure no other services are using ports 3389 or 8006
- **Performance issues**: Verify KVM acceleration is available (`/dev/kvm` device)

Perfect for occasional Windows-only tasks while staying in your Linux workflow.
