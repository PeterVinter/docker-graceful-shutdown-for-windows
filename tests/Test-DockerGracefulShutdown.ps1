BeforeAll {
    $scriptPath = Split-Path -Parent $PSScriptRoot
    $mainScript = Join-Path $scriptPath "gracefully_shutdown_all_docker_containers.ps1"
    . $mainScript
}

Describe "Docker Graceful Shutdown Tests" {
    Context "Container Dependency Detection" {
        It "Should detect direct container dependencies" {
            # Mock docker network inspect
            Mock docker {
                return @"
[
    {
        "Name": "test_network",
        "Containers": {
            "container1": {},
            "container2": {}
        }
    }
]
"@ | ConvertFrom-Json
            } -ParameterFilter { $args -contains "network" -and $args -contains "inspect" }

            $dependencies = Get-ContainerDependencies
            $dependencies | Should -Not -BeNull
        }
    }

    Context "Shutdown Order Calculation" {
        It "Should handle simple dependency chain" {
            $dependencies = @{
                "web" = @("api")
                "api" = @("db")
                "db" = @()
            }

            $order = Get-ShutdownOrder $dependencies
            $order.Count | Should -Be 3
            $order[0] | Should -Be "web"
            $order[1] | Should -Be "api"
            $order[2] | Should -Be "db"
        }
    }

    Context "Progress Display" {
        It "Should format progress message correctly" {
            $containerName = "test-container"
            $status = "Stopping"
            $progress = 50

            $message = Show-Progress $containerName $status $progress
            $message | Should -Match $containerName
            $message | Should -Match $status
            $message | Should -Match "50%"
        }
    }
}

Describe "Error Handling" {
    Context "Docker Command Failures" {
        It "Should handle docker command failures gracefully" {
            Mock docker { throw "Docker command failed" }

            { Stop-DockerContainer "test-container" } | 
                Should -Throw "Failed to stop container"
        }
    }
}
