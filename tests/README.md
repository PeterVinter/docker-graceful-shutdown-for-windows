# Tests

This directory contains tests for the Docker Graceful Shutdown utility.

## Test Categories

1. **Basic Functionality Tests** (`Test-DockerGracefulShutdown.ps1`)
   - Core script functionality
   - Docker environment checks
   - Container management operations
   - Error handling
   - Progress display formatting

2. **Dependency Tests** (`Test-Dependencies.ps1`)
   - Network dependency detection
     * Basic network dependencies
     * Multi-network container relationships
     * Custom network isolation
   - Docker Compose dependency resolution
     * Direct dependencies via depends_on
     * Network-based implicit dependencies
   - Complex multi-network scenarios
     * Microservices architecture simulation
     * Frontend/Backend separation
     * Database tier isolation
   - Dependency graph validation
   - Shutdown order verification

## Test Safety

All tests are designed to be safe and isolated:
- Test containers use unique prefixed names (e.g., `test-graceful-shutdown-`)
- Automatic cleanup after each test
- No interference with existing containers
- Separate test networks and resources
- Validation checks to prevent interaction with non-test containers

## Running Tests

### Prerequisites
```powershell
# Install required modules
Install-Module -Name Pester -Force -SkipPublisherCheck
```

### Local Testing
```powershell
# Run all tests
Invoke-Pester ./tests/*.ps1 -Output Detailed

# Run specific test categories
Invoke-Pester ./tests/Test-DockerGracefulShutdown.ps1 -Output Detailed
Invoke-Pester ./tests/Test-Dependencies.ps1 -Output Detailed
```

### Automated Testing

This project uses GitHub Actions for automated testing on Windows environments. The workflow:
1. Sets up Windows environment
2. Installs required PowerShell modules
3. Starts Docker Desktop
4. Runs all test categories
5. Reports test results

The GitHub Actions workflow configuration can be found in `.github/workflows/test-powershell.yml`.

## Test Examples

### Basic Container Test
```powershell
Describe "Basic Container Operations" {
    It "Should gracefully stop a single container" {
        # Test code here
    }
}
```

### Dependency Test
```powershell
Describe "Container Dependencies" {
    It "Should detect network dependencies" {
        # Test code here
    }
}
```

## Test Coverage

The dependency tests now cover:
1. **Basic Network Dependencies**
   - Containers in the same network
   - Network isolation verification
   - Default bridge network handling

2. **Docker Compose Scenarios**
   - Multi-tier application setups
   - Network-based dependencies
   - Service discovery patterns

3. **Complex Dependencies**
   - Multiple network attachments
   - Cross-network dependencies
   - Service mesh patterns
   - Microservices architectures

## Contributing Tests

When adding new tests:
1. Follow the existing test structure
2. Use descriptive test names
3. Include cleanup in `AfterAll` blocks
4. Add test documentation
5. Verify safety measures

## Troubleshooting

Common issues and solutions:
1. Docker not running
2. Permission issues
3. Network conflicts
4. Resource limitations
