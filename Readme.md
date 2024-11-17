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
    # Checks for:
    # 1. Network mode dependencies
    # 2. Container links
    # 3. Docker Compose dependencies
}
```

Maps out how containers depend on each other.

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

Want to contribute? Here's how:

1. **Fork the Repository**
   - Click the 'Fork' button at the top right of this page
   - This creates a copy of the repository in your GitHub account

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/docker-graceful-shutdown-for-windows.git
   cd docker-graceful-shutdown-for-windows
   ```

3. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-fix-name
   ```
   Name your branch based on what you're working on:
   - Use `feature/` prefix for new features
   - Use `fix/` prefix for bug fixes

4. **Make Your Changes**
   - Make your changes to the code
   - Test your changes thoroughly
   - Commit your changes with clear messages:
     ```bash
     git add .
     git commit -m "Add: detailed description of your changes"
     ```

5. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Go to your fork on GitHub
   - Click 'New Pull Request'
   - Select your branch and submit the PR
   - Provide a clear description of your changes

7. **Code Review**
   - Wait for review from the maintainers
   - Make any requested changes
   - Your PR will be merged when approved

## License

MIT License - Feel free to modify and distribute
