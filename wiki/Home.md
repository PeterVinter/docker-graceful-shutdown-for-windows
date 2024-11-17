# Docker Graceful Shutdown for Windows Wiki

Welcome to the Docker Graceful Shutdown for Windows wiki! This wiki provides detailed information about using and troubleshooting the utility.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Use Cases](#use-cases)
3. [Troubleshooting](#troubleshooting)
4. [Advanced Usage](#advanced-usage)

## Getting Started

### Prerequisites
- Windows OS
- PowerShell 5.1 or higher
- Docker Desktop for Windows
- Administrator privileges (recommended)

### Installation
1. Download both script files:
   - `shutdownallcontainers.cmd`
   - `gracefully_shutdown_all_docker_containers.ps1`
2. Place them in the same directory
3. Ensure you have execution permissions

## Use Cases

### 1. Development Environment Shutdown
Perfect for developers who need to cleanly shut down their development environment at the end of the day.

### 2. System Maintenance
Use before system updates or maintenance to ensure all containers are properly stopped.

### 3. Container Dependency Management
Handles complex container dependencies automatically during shutdown.

## Troubleshooting

### Common Issues

#### 1. Permission Denied
```powershell
Solution: Run the script as Administrator
```

#### 2. Docker Not Running
```powershell
Solution: Ensure Docker Desktop is running and accessible
```

#### 3. Timeout Issues
```powershell
Solution: Adjust timeout settings in the PowerShell script
```

## Advanced Usage

### Custom Timeout Settings
You can modify the default timeout value in the PowerShell script:
```powershell
$timeout = 30  # Adjust this value as needed
```

### Dependency Override
To force shutdown regardless of dependencies:
```cmd
shutdownallcontainers.cmd -force
```

## Contributing to the Wiki

Feel free to contribute to this wiki by:
1. Creating new pages for specific topics
2. Adding more troubleshooting scenarios
3. Sharing your use cases
4. Improving existing documentation
