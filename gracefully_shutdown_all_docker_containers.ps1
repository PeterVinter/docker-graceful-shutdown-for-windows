#Requires -Version 5.1

<#
.SYNOPSIS
    Gracefully shuts down Docker containers respecting their dependencies.
.DESCRIPTION
    This script analyzes Docker container dependencies and performs a graceful shutdown
    in the correct order to prevent issues with dependent services.
.NOTES
    File Name      : gracefully_shutdown_all_docker_containers.ps1
    Prerequisite   : Docker Desktop must be running
    Version        : 1.0
#>

function Show-Progress {
    <#
    .SYNOPSIS
        Displays a progress bar for container operations.
    .DESCRIPTION
        Shows a visual progress bar with percentage and container status.
    .PARAMETER ContainerName
        The name of the container being processed.
    .PARAMETER Status
        The current status of the operation.
    .EXAMPLE
        Show-Progress -ContainerName "web-app" -Status "Shutting down"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ContainerName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Status
    )
    
    $ProgressBar = ''
    for ($i = 0; $i -le 100; $i += 5) {
        $ProgressBar = '#' * ($i / 5)
        Write-Host -NoNewline "`r    [$ProgressBar] ${i}% - $ContainerName : $Status                    "
        Start-Sleep -Milliseconds 50
    }
    Write-Host -NoNewline "`r    [####################] 100% - $ContainerName : Stopped                    "
    Write-Host
}

function Get-ContainerDependencies {
    <#
    .SYNOPSIS
        Retrieves Docker container dependencies.
    .DESCRIPTION
        Analyzes Docker containers and their network connections to build a dependency map.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()
    
    $RunningContainers = docker ps -q
    if (-not $RunningContainers) {
        return @{}
    }
    
    $Containers = docker inspect $RunningContainers | ConvertFrom-Json
    $DependencyMap = @{}
    $NetworkMap = @{}
    
    # First, build a map of networks and their containers
    foreach ($Container in $Containers) {
        $Name = $Container.Name.TrimStart('/')
        
        foreach ($Network in $Container.NetworkSettings.Networks.PSObject.Properties) {
            $NetworkName = $Network.Name
            if (-not $NetworkMap.ContainsKey($NetworkName)) {
                $NetworkMap[$NetworkName] = [System.Collections.ArrayList]@()
            }
            [void]$NetworkMap[$NetworkName].Add($Name)
        }
    }
    
    # Now build the dependency map
    foreach ($Container in $Containers) {
        $Name = $Container.Name.TrimStart('/')
        $Links = [System.Collections.ArrayList]@()
        
        # Get container dependencies from NetworkMode
        if ($Container.HostConfig.NetworkMode -match "^container:(.+)$") {
            [void]$Links.Add($matches[1])
        }
        
        # Get dependencies from Links
        if ($Container.HostConfig.Links) {
            $ContainerLinks = $Container.HostConfig.Links | ForEach-Object {
                $_ -split ':' | Select-Object -First 1
            }
            foreach ($Link in $ContainerLinks) {
                [void]$Links.Add($Link)
            }
        }
        
        # Get dependencies from DependsOn
        if ($Container.Config.Labels.'com.docker.compose.depends_on') {
            $DependsOn = $Container.Config.Labels.'com.docker.compose.depends_on' -split ','
            foreach ($Dep in $DependsOn) {
                [void]$Links.Add($Dep.Trim())
            }
        }
        
        # Get dependencies from shared networks
        foreach ($Network in $Container.NetworkSettings.Networks.PSObject.Properties) {
            $NetworkName = $Network.Name
            if ($NetworkName -ne 'bridge' -and $NetworkMap.ContainsKey($NetworkName)) {
                foreach ($NetworkContainer in $NetworkMap[$NetworkName]) {
                    if ($NetworkContainer -ne $Name) {
                        [void]$Links.Add($NetworkContainer)
                    }
                }
            }
        }
        
        $DependencyMap[$Name] = $Links | Select-Object -Unique
    }
    
    return $DependencyMap
}

function Get-ShutdownOrder {
    <#
    .SYNOPSIS
        Determines the correct order for shutting down containers.
    .DESCRIPTION
        Uses a topological sort to determine the proper shutdown order based on container dependencies.
    .PARAMETER DependencyMap
        Hashtable containing container dependencies.
    .OUTPUTS
        System.Collections.ArrayList
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]$DependencyMap
    )
    
    $Visited = @{}
    $ShutdownOrder = [System.Collections.ArrayList]@()
    
    function Visit-Node {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [String]$Node
        )
        
        if ($Visited[$Node] -eq 1) {
            Write-Warning "Circular dependency detected at container: $Node"
            return
        }
        
        if ($Visited[$Node] -eq 2) { return }
        
        $Visited[$Node] = 1
        foreach ($Dep in $DependencyMap[$Node]) {
            if ($DependencyMap.ContainsKey($Dep)) {
                Visit-Node -Node $Dep
            }
        }
        $Visited[$Node] = 2
        [void]$ShutdownOrder.Add($Node)
    }
    
    foreach ($Container in $DependencyMap.Keys) {
        if (-not $Visited[$Container]) {
            Visit-Node -Node $Container
        }
    }
    
    return $ShutdownOrder
}

# Main script execution
try {
    $ErrorActionPreference = 'Stop'
    
    Write-Host "Getting running containers and their dependencies..."
    $Dependencies = Get-ContainerDependencies
    if ($Dependencies.Count -eq 0) {
        Write-Host "No running containers found."
        exit 0
    }
    
    Write-Host "Calculating shutdown order..."
    $ShutdownOrder = Get-ShutdownOrder -DependencyMap $Dependencies
    
    Write-Host "Starting graceful shutdown in the following order:"
    $ShutdownOrder | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    
    foreach ($Container in $ShutdownOrder) {
        Write-Host "Processing container: $Container"
        
        # Show initial progress
        Show-Progress -ContainerName $Container -Status "Shutting down"
        
        # Send SIGTERM signal and wait for graceful shutdown
        $StopResult = docker stop --time=30 $Container 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Warning: Failed to stop container $Container gracefully. Error: $StopResult"
            Show-Progress -ContainerName $Container -Status "Force stopping"
            $KillResult = docker kill $Container 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to force stop container $Container. Error: $KillResult"
            }
        }
    }
    
    Write-Host "`nAll containers have been stopped successfully."
}
catch {
    Write-Error "An error occurred during container shutdown: $_"
    exit 1
}