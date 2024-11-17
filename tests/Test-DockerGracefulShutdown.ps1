BeforeAll {
    $scriptPath = Split-Path -Parent $PSScriptRoot
    $mainScript = Join-Path $scriptPath "gracefully_shutdown_all_docker_containers.ps1"
    . $mainScript
}

Describe "Docker Graceful Shutdown Tests" {
    Context "Basic Script Functionality" {
        It "Script file should exist" {
            Test-Path $mainScript | Should -Be $true
        }

        It "Script should be valid PowerShell" {
            $psFile = Get-Content $mainScript -Raw
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }

    Context "Docker Environment" {
        It "Docker should be installed" {
            Get-Command docker -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Docker daemon should be running" {
            $dockerInfo = docker info 2>&1
            $dockerInfo | Should -Not -Match "Cannot connect to the Docker daemon"
        }
    }

    Context "Docker Container Management" {
        BeforeAll {
            # Create a test container that we can safely stop
            docker run --name test-container -d nginx
            Start-Sleep -Seconds 2
        }

        It "Should be able to list running containers" {
            $containers = docker ps --format "{{.Names}}"
            $containers | Should -Not -BeNullOrEmpty
            $containers | Should -Contain "test-container"
        }

        It "Should be able to stop containers" {
            docker stop test-container
            $containers = docker ps --format "{{.Names}}"
            $containers | Should -Not -Contain "test-container"
        }

        AfterAll {
            # Cleanup
            docker rm test-container -f 2>$null
        }
    }
}

Describe "Script Functions" {
    Context "Show-Progress Function" {
        It "Should have Show-Progress function" {
            ${function:Show-Progress} | Should -Not -BeNullOrEmpty
        }

        It "Should accept containerName and status parameters" {
            $function = ${function:Show-Progress}.ToString()
            $function | Should -Match "param\s*\(\s*\[string\]\s*\`$containerName\s*,\s*\[string\]\s*\`$status\s*\)"
        }
    }

    Context "Get-ContainerDependencies Function" {
        It "Should have Get-ContainerDependencies function" {
            ${function:Get-ContainerDependencies} | Should -Not -BeNullOrEmpty
        }
    }

    Context "Get-ShutdownOrder Function" {
        It "Should have Get-ShutdownOrder function" {
            ${function:Get-ShutdownOrder} | Should -Not -BeNullOrEmpty
        }

        It "Should accept DependencyMap parameter" {
            $function = ${function:Get-ShutdownOrder}.ToString()
            $function | Should -Match "\[Parameter\(Mandatory\s*=\s*\`$true\)\]"
            $function | Should -Match "\[hashtable\]\s*\`$DependencyMap"
        }
    }
}
