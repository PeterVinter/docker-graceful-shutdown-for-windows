# Docker Graceful Shutdown Utility

![License](https://img.shields.io/github/license/PeterVinter/docker-graceful-shutdown-for-windows)
![Last Commit](https://img.shields.io/github/last-commit/PeterVinter/docker-graceful-shutdown-for-windows)
![Stars](https://img.shields.io/github/stars/PeterVinter/docker-graceful-shutdown-for-windows)
![Issues](https://img.shields.io/github/issues/PeterVinter/docker-graceful-shutdown-for-windows)
![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=flat&logo=powershell&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)

A PowerShell-based utility for gracefully shutting down Docker containers with dependency awareness and visual progress tracking.

## Files Explained

### shutdownallcontainers.cmd

```batch
@echo off
setlocal EnableDelayedExpansion
color 0B
...
```

This is the launcher script that:

- Provides a user-friendly interface
- Checks for required files and permissions
- Executes the PowerShell script
- Displays results

### gracefully_shutdown_all_docker_containers.ps1

```powershell
# Function to show progress bar
function Show-Progress {
    param (
        [string]$containerName,
        [string]$status
    )
    ...
}
```

This is the main PowerShell script that handles:

- Container dependency detection
- Shutdown order calculation
- Progress visualization
- Graceful shutdown logic

## How the PowerShell Script Works

### Progress Bar Function

```powershell
function Show-Progress {
    # Shows a progress bar like:
    # [##########] 50% - container_name : Shutting down
}
```

Creates a visual progress indicator for each container being shut down.

### Container Dependencies

```powershell
function Get-ContainerDependencies {
    # Detects dependencies through:
    # 1. Network mode dependencies (--network container:name)
    # 2. Container links (--link)
    # 3. Docker Compose dependencies (depends_on)
    # 4. Shared networks (containers in same non-default network)
}
```

The dependency detection system now includes:
- Network-based dependency detection for containers sharing custom networks
- Multi-network support for containers connected to multiple networks
- Proper handling of Docker Compose relationships
- Circular dependency detection and resolution

### Shutdown Order

```powershell
function Get-ShutdownOrder {
    # Uses topological sorting to determine
    # safe shutdown order
}
```

Calculates the correct order to shut down containers without breaking dependencies.

### Main Execution

```powershell
try {
    # 1. Get dependencies
    # 2. Calculate order
    # 3. Show progress
    # 4. Shut down containers
}
```

Orchestrates the entire shutdown process.

## Usage

1. Place both files in the same directory
2. Run `shutdownallcontainers.cmd`
3. Watch the progress as containers are gracefully stopped

## Example Output

```
+------------------------------------------------+
|           Docker Graceful Shutdown Tool          |
+------------------------------------------------+

Processing container: container1
    [####################] 100% - container1 : Stopped
```

## Requirements

- Windows OS
- PowerShell 5.1+
- Docker Desktop
- Admin rights (recommended)

## Tips

- Keep both files together
- Run as administrator
- Default timeout is 30 seconds per container
- Failed graceful shutdowns will attempt force stop

## Error Handling

The script handles:

- Missing files
- Permission issues
- Failed shutdowns
- Circular dependencies

## Support

For issues or questions:

1. Check file permissions
2. Verify Docker is running
3. Run as administrator
4. Check for circular dependencies

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:
- How to submit changes
- How to report issues
- Coding standards
- Development process

## Development Setup

### Prerequisites for Development
- Windows 10/11
- PowerShell 5.1 or higher
- Docker Desktop for Windows
- Git
- Your favorite code editor (VS Code recommended)

### Development Environment Setup
1. Clone the repository
   ```bash
   git clone https://github.com/PeterVinter/docker-graceful-shutdown-for-windows.git
   cd docker-graceful-shutdown-for-windows
   ```

2. Set up PowerShell execution policy (if needed)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Test the scripts
   ```cmd
   shutdownallcontainers.cmd -test
   ```

### Code Style Guidelines
- Use clear, descriptive variable names
- Add comments for complex logic
- Follow [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)

### Testing
Before submitting changes:
1. Run the script with `-test` parameter
2. Test with various container configurations
3. Verify proper error handling
4. Check script performance

## Testing

The project includes comprehensive test coverage using Pester framework and GitHub Actions:
- Automated testing on Windows environments
- Safe and isolated test execution
- Extensive test scenarios

For detailed testing information, see [tests/README.md](tests/README.md).

## Examples

The `/examples` directory contains several scenarios demonstrating the utility's capabilities:

1. Basic Web Stack ([examples/basic-web](examples/basic-web))
   - Simple web application with database
   - Basic network dependencies

2. Microservices Architecture ([examples/microservices-example](examples/microservices-example))
   - Multi-layer application architecture
   - Complex network topology
   - See directory README for details

## Logging

The utility includes comprehensive logging functionality:

- File-based logging in `./logs`
- Console output with color-coding
- Multiple log levels (INFO, WARNING, ERROR, DEBUG)

Enable verbose logging:
```powershell
$VerbosePreference = 'Continue'
.\gracefully_shutdown_all_docker_containers.ps1
```

For more details about logging configuration, see [modules/Logging.psm1](modules/Logging.psm1).

## License

MIT License - Feel free to modify and distribute
