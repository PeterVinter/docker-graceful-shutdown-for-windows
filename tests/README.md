# Tests

This directory contains tests for the Docker Graceful Shutdown utility.

## Test Categories

1. **Unit Tests**
   - Container dependency detection
   - Shutdown order calculation
   - Progress display formatting
   - Error handling

2. **Integration Tests**
   - Full shutdown sequence
   - Network dependency handling
   - Timeout handling

## Running Tests

### Prerequisites
- Pester (PowerShell testing framework)
- Docker Desktop running
- Test containers (will be created automatically)

### Install Pester
```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

### Run All Tests
```powershell
Invoke-Pester .\Test-DockerGracefulShutdown.ps1
```

### Run Specific Test Categories
```powershell
Invoke-Pester .\Test-DockerGracefulShutdown.ps1 -Tag "UnitTest"
```

## Test Coverage

Current test coverage includes:
- Container dependency detection
- Shutdown order calculation
- Progress display
- Error handling
- Docker command interaction

## Adding New Tests

When adding new tests:
1. Follow the existing test structure
2. Add appropriate mocks for Docker commands
3. Test both success and failure scenarios
4. Add comments explaining complex test cases
