BeforeAll {
    $scriptPath = Split-Path -Parent $PSScriptRoot
    $mainScript = Join-Path $scriptPath "gracefully_shutdown_all_docker_containers.ps1"
    . $mainScript

    # Helper function to ensure test containers are cleaned up
    function Remove-TestContainers {
        Write-Host "Cleaning up test containers..."
        docker ps -a --filter "name=test-graceful-" -q | ForEach-Object { 
            docker stop $_ 2>$null
            docker rm $_ 2>$null 
        }
        docker network ls --filter "name=test-graceful-" -q | ForEach-Object { 
            docker network rm $_ 2>$null 
        }
    }

    # Helper function to verify container is running
    function Test-ContainerRunning {
        param($containerName)
        $status = docker inspect -f '{{.State.Running}}' $containerName 2>$null
        return $status -eq 'true'
    }

    # Clean up any leftover test containers before starting
    Remove-TestContainers
}

Describe "Container Dependency Tests" {
    Context "Network Dependencies" {
        BeforeAll {
            Write-Host "Setting up network dependencies test..."
            # Create test containers with network dependencies
            docker network create test-graceful-network
            docker run -d --name test-graceful-db --network test-graceful-network nginx
            docker run -d --name test-graceful-api --network test-graceful-network nginx
            docker run -d --name test-graceful-web --network test-graceful-network nginx
            Start-Sleep -Seconds 2

            # Verify containers are running
            $containers = @('test-graceful-db', 'test-graceful-api', 'test-graceful-web')
            foreach ($container in $containers) {
                if (-not (Test-ContainerRunning $container)) {
                    throw "Container $container failed to start"
                }
                Write-Host "Container $container is running"
            }
        }

        It "Should detect containers in the same network" {
            # List running containers for debugging
            Write-Host "Currently running containers:"
            docker ps
            
            $dependencies = Get-ContainerDependencies
            Write-Host "Dependencies found: $($dependencies | ConvertTo-Json)"
            $dependencies | Should -Not -BeNullOrEmpty
            
            # Check if our test containers are in the dependencies
            $testContainers = $dependencies.Keys | Where-Object { $_ -like "test-graceful-*" }
            $testContainers.Count | Should -BeGreaterThan 0
        }

        AfterAll {
            Remove-TestContainers
        }
    }

    Context "Docker Compose Dependencies" {
        BeforeAll {
            Write-Host "Setting up Docker Compose dependencies test..."
            # Create a test compose environment
            docker network create test-graceful-frontend
            docker network create test-graceful-backend
            
            # Create containers in specific order
            docker run -d --name test-graceful-db --network test-graceful-backend nginx
            Start-Sleep -Seconds 1
            docker run -d --name test-graceful-api --network test-graceful-backend nginx
            Start-Sleep -Seconds 1
            docker run -d --name test-graceful-web --network test-graceful-frontend --network test-graceful-backend nginx
            Start-Sleep -Seconds 2

            # Verify containers are running
            $containers = @('test-graceful-db', 'test-graceful-api', 'test-graceful-web')
            foreach ($container in $containers) {
                if (-not (Test-ContainerRunning $container)) {
                    throw "Container $container failed to start"
                }
                Write-Host "Container $container is running"
            }
        }

        It "Should detect network-based dependencies" {
            # List running containers for debugging
            Write-Host "Currently running containers:"
            docker ps
            
            $dependencies = Get-ContainerDependencies
            Write-Host "Dependencies found: $($dependencies | ConvertTo-Json)"
            $dependencies | Should -Not -BeNullOrEmpty
            
            # Web should depend on API and DB due to shared networks
            $webDeps = $dependencies["test-graceful-web"]
            $webDeps | Should -Contain "test-graceful-api"
            $webDeps | Should -Contain "test-graceful-db"
        }

        AfterAll {
            Remove-TestContainers
        }
    }

    Context "Complex Dependencies" {
        BeforeAll {
            Write-Host "Setting up complex dependencies test..."
            # Create a more complex network topology
            docker network create test-graceful-frontend
            docker network create test-graceful-backend
            
            # Database tier
            docker run -d --name test-graceful-redis --network test-graceful-backend redis:alpine
            docker run -d --name test-graceful-mongodb --network test-graceful-backend mongo:latest
            
            # Application tier
            docker run -d --name test-graceful-api1 --network test-graceful-backend nginx
            docker run -d --name test-graceful-api2 --network test-graceful-backend nginx
            
            # Frontend tier
            docker run -d --name test-graceful-web1 --network test-graceful-frontend --network test-graceful-backend nginx
            docker run -d --name test-graceful-web2 --network test-graceful-frontend --network test-graceful-backend nginx
            
            Start-Sleep -Seconds 2

            # Verify containers are running
            $containers = @(
                'test-graceful-redis', 'test-graceful-mongodb',
                'test-graceful-api1', 'test-graceful-api2',
                'test-graceful-web1', 'test-graceful-web2'
            )
            foreach ($container in $containers) {
                if (-not (Test-ContainerRunning $container)) {
                    throw "Container $container failed to start"
                }
                Write-Host "Container $container is running"
            }
        }

        It "Should handle multiple network dependencies" {
            # List running containers for debugging
            Write-Host "Currently running containers:"
            docker ps
            
            $dependencies = Get-ContainerDependencies
            Write-Host "Dependencies found: $($dependencies | ConvertTo-Json)"
            $dependencies | Should -Not -BeNullOrEmpty
            
            # Frontend containers should depend on backend services
            $web1Deps = $dependencies["test-graceful-web1"]
            $web2Deps = $dependencies["test-graceful-web2"]
            
            $web1Deps | Should -Contain "test-graceful-api1"
            $web1Deps | Should -Contain "test-graceful-api2"
            $web2Deps | Should -Contain "test-graceful-api1"
            $web2Deps | Should -Contain "test-graceful-api2"
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
