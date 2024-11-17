# Examples

This directory contains example configurations and use cases for the Docker Graceful Shutdown utility.

## Example Scenarios

### 1. Basic Web Stack (`docker-compose.yml`)
A typical web application stack with:
- Nginx web server
- .NET Core API
- SQL Server database

This example demonstrates:
- Container dependencies
- Network configuration
- Multi-tier architecture shutdown

### Running the Example

1. Start the containers:
```bash
docker-compose up -d
```

2. Run the shutdown script:
```cmd
..\shutdownallcontainers.cmd
```

Observe how the containers are shut down in the correct order:
1. Web server (depends on API)
2. API service (depends on DB)
3. Database (no dependencies)

## Common Use Cases

### 1. Development Environment
```powershell
# Start development environment
docker-compose up -d

# Work on your project...

# End of day - gracefully shutdown
.\shutdownallcontainers.cmd
```

### 2. System Maintenance
```powershell
# Before Windows updates
.\shutdownallcontainers.cmd -timeout 60
```

### 3. Resource Management
```powershell
# Free up system resources
.\shutdownallcontainers.cmd -force
```
