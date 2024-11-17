#Requires -Version 5.1
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

<#
.SYNOPSIS
    Tests for Docker container dependency detection and graceful shutdown.
.DESCRIPTION
    This Pester test suite validates the functionality of the Docker container
    dependency detection and graceful shutdown script. It tests various scenarios
    including network dependencies, Docker Compose dependencies, and complex
    multi-container setups.
.NOTES
    File Name      : Test-Dependencies.ps1
    Prerequisite   : Docker Desktop must be running
                    Pester 5.0.0 or later
    Version        : 1.0
#>

BeforeAll {
    $ErrorActionPreference = 'Stop'
    $ScriptPath = Split-Path -Parent $PSScriptRoot
    $MainScript = Join-Path $ScriptPath "gracefully_shutdown_all_docker_containers.ps1"
    . $MainScript

    function Remove-TestContainers {
        <#
        .SYNOPSIS
            Cleans up test containers and networks.
        .DESCRIPTION
            Removes all test containers and networks created during testing,
            identified by the 'test-graceful-' prefix.
        #>
        [CmdletBinding()]
        param()
        
        Write-Host "Cleaning up test containers..."
        try {
            $TestContainers = docker ps -a --filter "name=test-graceful-" -q
            if ($TestContainers) {
                $TestContainers | ForEach-Object { 
                    docker stop $_ 2>$null
                    docker rm $_ 2>$null 
                }
            }

            $TestNetworks = docker network ls --filter "name=test-graceful-" -q
            if ($TestNetworks) {
                $TestNetworks | ForEach-Object { 
                    docker network rm $_ 2>$null 
                }
            }
        }
        catch {
            Write-Warning "Error during cleanup: $_"
        }
    }

    function Test-ContainerRunning {
        <#
        .SYNOPSIS
            Verifies if a Docker container is running.
        .PARAMETER ContainerName
            The name of the container to check.
        .OUTPUTS
            System.Boolean. True if the container is running, false otherwise.
        #>
        [CmdletBinding()]
        [OutputType([bool])]
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$ContainerName
        )
        
        try {
            $Status = docker inspect -f '{{.State.Running}}' $ContainerName 2>$null
            return $Status -eq 'true'
        }
        catch {
            return $false
        }
    }

    function Wait-ContainerStart {
        <#
        .SYNOPSIS
            Waits for containers to be in running state.
        .PARAMETER ContainerNames
            Array of container names to check.
        .PARAMETER TimeoutSeconds
            Maximum time to wait for containers to start.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$ContainerNames,
            
            [Parameter()]
            [int]$TimeoutSeconds = 30
        )

        $StartTime = Get-Date
        $AllRunning = $false

        while (-not $AllRunning -and ((Get-Date) - $StartTime).TotalSeconds -lt $TimeoutSeconds) {
            $AllRunning = $true
            foreach ($Container in $ContainerNames) {
                if (-not (Test-ContainerRunning -ContainerName $Container)) {
                    $AllRunning = $false
                    Start-Sleep -Seconds 1
                    break
                }
            }
        }

        foreach ($Container in $ContainerNames) {
            if (Test-ContainerRunning -ContainerName $Container) {
                Write-Host "Container $Container is running"
            }
            else {
                throw "Container $Container failed to start within $TimeoutSeconds seconds"
            }
        }
    }

    # Clean up any leftover test containers before starting
    Remove-TestContainers
}

Describe "Container Dependency Tests" {
    Context "When testing network dependencies" {
        BeforeAll {
            Write-Host "Setting up network dependencies test..."
            
            # Create test containers with network dependencies
            docker network create test-graceful-network
            docker run -d --name test-graceful-db --network test-graceful-network nginx
            docker run -d --name test-graceful-api --network test-graceful-network nginx
            docker run -d --name test-graceful-web --network test-graceful-network nginx

            $TestContainers = @('test-graceful-db', 'test-graceful-api', 'test-graceful-web')
            Wait-ContainerStart -ContainerNames $TestContainers
        }

        It "Should detect containers in the same network" {
            # List running containers for debugging
            Write-Host "Currently running containers:"
            docker ps
            
            $Dependencies = Get-ContainerDependencies
            Write-Host "Dependencies found: $($Dependencies | ConvertTo-Json)"
            
            # Verify dependencies
            $Dependencies | Should -Not -BeNullOrEmpty
            $TestContainers = $Dependencies.Keys | Where-Object { $_ -like "test-graceful-*" }
            $TestContainers.Count | Should -BeGreaterThan 0
        }

        AfterAll {
            Remove-TestContainers
        }
    }

    Context "When testing Docker Compose style dependencies" {
        BeforeAll {
            Write-Host "Setting up Docker Compose dependencies test..."
            
            # Create networks
            docker network create test-graceful-frontend
            docker network create test-graceful-backend
            
            # Create containers in specific order
            docker run -d --name test-graceful-db --network test-graceful-backend nginx
            docker run -d --name test-graceful-api --network test-graceful-backend nginx
            docker run -d --name test-graceful-web --network test-graceful-frontend --network test-graceful-backend nginx

            $TestContainers = @('test-graceful-db', 'test-graceful-api', 'test-graceful-web')
            Wait-ContainerStart -ContainerNames $TestContainers
        }

        It "Should detect network-based dependencies" {
            Write-Host "Currently running containers:"
            docker ps
            
            $Dependencies = Get-ContainerDependencies
            Write-Host "Dependencies found: $($Dependencies | ConvertTo-Json)"
            
            # Verify dependencies
            $Dependencies | Should -Not -BeNullOrEmpty
            $WebDeps = $Dependencies["test-graceful-web"]
            $WebDeps | Should -Contain "test-graceful-api"
            $WebDeps | Should -Contain "test-graceful-db"
        }

        AfterAll {
            Remove-TestContainers
        }
    }

    Context "When testing complex multi-tier dependencies" {
        BeforeAll {
            Write-Host "Setting up complex dependencies test..."
            
            # Create networks
            docker network create test-graceful-frontend
            docker network create test-graceful-backend
            
            # Create containers for each tier
            docker run -d --name test-graceful-redis --network test-graceful-backend redis:alpine
            docker run -d --name test-graceful-mongodb --network test-graceful-backend mongo:latest
            docker run -d --name test-graceful-api1 --network test-graceful-backend nginx
            docker run -d --name test-graceful-api2 --network test-graceful-backend nginx
            docker run -d --name test-graceful-web1 --network test-graceful-frontend --network test-graceful-backend nginx
            docker run -d --name test-graceful-web2 --network test-graceful-frontend --network test-graceful-backend nginx

            $TestContainers = @(
                'test-graceful-redis', 'test-graceful-mongodb',
                'test-graceful-api1', 'test-graceful-api2',
                'test-graceful-web1', 'test-graceful-web2'
            )
            Wait-ContainerStart -ContainerNames $TestContainers
        }

        It "Should handle multiple network dependencies" {
            Write-Host "Currently running containers:"
            docker ps
            
            $Dependencies = Get-ContainerDependencies
            Write-Host "Dependencies found: $($Dependencies | ConvertTo-Json)"
            
            # Verify dependencies
            $Dependencies | Should -Not -BeNullOrEmpty
            $Web1Deps = $Dependencies["test-graceful-web1"]
            $Web2Deps = $Dependencies["test-graceful-web2"]
            
            $Web1Deps | Should -Contain "test-graceful-api1"
            $Web1Deps | Should -Contain "test-graceful-api2"
            $Web2Deps | Should -Contain "test-graceful-api1"
            $Web2Deps | Should -Contain "test-graceful-api2"
        }

        AfterAll {
            Remove-TestContainers
        }
    }

    AfterAll {
        # Final cleanup
        Remove-TestContainers
    }
}
