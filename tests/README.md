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
   - Complex multi-tier scenarios
     * Microservices architecture simulation
     * Frontend/Backend separation
     * Database tier isolation
   - Dependency graph validation
   - Shutdown order verification
   - Circular dependency detection
   - Intelligent dependency resolution

## Test Safety

All tests are designed to be safe and isolated:
- Test containers use unique prefixed names (e.g., `test-graceful-`)
- Automatic cleanup after each test run
- No interference with existing containers
- Separate test networks and resources
- Validation checks to prevent interaction with non-test containers
- Error handling for container startup/shutdown
- Timeout mechanisms for container operations

## Running Tests

### Prerequisites
```powershell
# Requires PowerShell 5.1 or later
#Requires -Version 5.1
#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.0.0" }

# Install required modules
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck
```

### Local Testing
```powershell
# Run all tests with detailed output
Invoke-Pester ./tests/*.ps1 -Output Detailed

# Run specific test categories
Invoke-Pester ./tests/Test-DockerGracefulShutdown.ps1 -Output Detailed
Invoke-Pester ./tests/Test-Dependencies.ps1 -Output Detailed
```

### Test Structure

The tests follow PowerShell best practices:
- Comment-based help for all test files
- Proper function documentation
- Type declarations for parameters
- Error handling with try-catch blocks
- Cleanup in finally blocks
- Helper functions for common operations
- Descriptive test contexts and names

## Test Scenarios

### Network Dependencies Test
```powershell
Describe "Container Dependency Tests" {
    Context "When testing network dependencies" {
        It "Should detect containers in the same network" {
            # Tests basic network dependency detection
        }
    }
}
```

### Docker Compose Dependencies Test
```powershell
Context "When testing Docker Compose style dependencies" {
    It "Should detect network-based dependencies" {
        # Tests compose-style dependency resolution
    }
}
```

### Complex Multi-Tier Test
```powershell
Context "When testing complex multi-tier dependencies" {
    It "Should handle multiple network dependencies" {
        # Tests complex microservices scenarios
    }
}
```

## Test Coverage

The dependency tests cover:

1. **Network Dependencies**
   - Basic container networking
   - Network isolation
   - Cross-network communication
   - Default bridge network handling

2. **Docker Compose Scenarios**
   - Multi-container applications
   - Service dependencies
   - Network-based service discovery
   - Container startup order

3. **Complex Dependencies**
   - Microservices architectures
   - Multi-tier applications
   - Database dependencies
   - Circular dependency detection
   - Load balancer scenarios
   - Shared resource management

## Helper Functions

The test suite includes several helper functions:
- `Wait-ContainerStart`: Smart container startup detection
- `New-TestContainer`: Creates containers for testing
- `Remove-TestContainers`: Cleans up test containers
- `Test-ContainerNetwork`: Validates network connectivity
- `Get-ContainerDependencies`: Analyzes container dependencies

## Error Handling

Tests include comprehensive error handling:
- Container startup failures
- Network creation issues
- Timeout scenarios
- Resource cleanup
- Invalid configurations
- Network connectivity problems
