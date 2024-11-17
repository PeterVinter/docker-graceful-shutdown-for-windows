BeforeAll {
    $scriptPath = Split-Path -Parent $PSScriptRoot
    $mainScript = Join-Path $scriptPath "gracefully_shutdown_all_docker_containers.ps1"
    . $mainScript
}

Describe "Container Dependency Tests" {
    Context "Network Dependencies" {
        BeforeAll {
            # Create test containers with network dependencies
            docker network create test-network
            docker run -d --name db --network test-network mcr.microsoft.com/mssql/server:2019-latest
            docker run -d --name api --network test-network nginx
            docker run -d --name web --network test-network nginx
            Start-Sleep -Seconds 2
        }

        It "Should detect containers in the same network" {
            $dependencies = Get-ContainerDependencies
            $dependencies | Should -Not -BeNullOrEmpty
            $dependencies.Keys | Should -Contain "web"
            $dependencies.Keys | Should -Contain "api"
            $dependencies.Keys | Should -Contain "db"
        }

        AfterAll {
            # Cleanup
            docker stop db api web 2>$null
            docker rm db api web 2>$null
            docker network rm test-network 2>$null
        }
    }

    Context "Docker Compose Dependencies" {
        BeforeAll {
            # Use the example docker-compose.yml
            $composePath = Join-Path $scriptPath "examples/docker-compose.yml"
            Push-Location (Split-Path $composePath)
            docker-compose up -d
            Start-Sleep -Seconds 5
        }

        It "Should detect docker-compose dependencies" {
            $dependencies = Get-ContainerDependencies
            $dependencies | Should -Not -BeNullOrEmpty
            
            # Check dependency order
            $order = Get-ShutdownOrder -DependencyMap $dependencies
            $webIndex = [array]::IndexOf($order, "web")
            $apiIndex = [array]::IndexOf($order, "api")
            $dbIndex = [array]::IndexOf($order, "db")
            
            $webIndex | Should -BeLessThan $apiIndex
            $apiIndex | Should -BeLessThan $dbIndex
        }

        AfterAll {
            # Cleanup
            docker-compose down
            Pop-Location
        }
    }

    Context "Complex Dependencies" {
        BeforeAll {
            # Create a more complex network topology
            docker network create frontend
            docker network create backend
            
            # Database tier
            docker run -d --name redis --network backend redis:alpine
            docker run -d --name mongodb --network backend mongo:latest
            
            # Application tier
            docker run -d --name api1 --network backend nginx
            docker run -d --name api2 --network backend nginx
            
            # Frontend tier
            docker run -d --name web1 --network frontend --network backend nginx
            docker run -d --name web2 --network frontend --network backend nginx
            
            Start-Sleep -Seconds 2
        }

        It "Should handle multiple network dependencies" {
            $dependencies = Get-ContainerDependencies
            $dependencies | Should -Not -BeNullOrEmpty
            
            # Frontend containers should be shut down first
            $order = Get-ShutdownOrder -DependencyMap $dependencies
            $web1Index = [array]::IndexOf($order, "web1")
            $web2Index = [array]::IndexOf($order, "web2")
            $api1Index = [array]::IndexOf($order, "api1")
            $api2Index = [array]::IndexOf($order, "api2")
            
            $web1Index | Should -BeLessThan $api1Index
            $web2Index | Should -BeLessThan $api2Index
        }

        AfterAll {
            # Cleanup
            docker stop redis mongodb api1 api2 web1 web2 2>$null
            docker rm redis mongodb api1 api2 web1 web2 2>$null
            docker network rm frontend backend 2>$null
        }
    }
}
