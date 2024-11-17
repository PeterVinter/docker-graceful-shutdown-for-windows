# Function to show progress bar
function Show-Progress {
    param (
        [string]$containerName,
        [string]$status
    )
    $progressBar = ''
    for ($i = 0; $i -le 100; $i += 5) {
        $progressBar = '#' * ($i / 5)
        Write-Host -NoNewline "`r    [$progressBar] ${i}% - $containerName : $status                    "
        Start-Sleep -Milliseconds 50
    }
    Write-Host -NoNewline "`r    [####################] 100% - $containerName : Stopped                    "
    Write-Host
}

# Rest of the script remains exactly the same...
function Get-ContainerDependencies {
    $runningContainers = docker ps -q
    if (-not $runningContainers) {
        return @{}
    }
    
    $containers = docker inspect $runningContainers | ConvertFrom-Json
    $dependencyMap = @{}
    $networkMap = @{}
    
    # First, build a map of networks and their containers
    foreach ($container in $containers) {
        $name = $container.Name.TrimStart('/')
        
        foreach ($network in $container.NetworkSettings.Networks.PSObject.Properties) {
            $networkName = $network.Name
            if (-not $networkMap.ContainsKey($networkName)) {
                $networkMap[$networkName] = [System.Collections.ArrayList]@()
            }
            [void]$networkMap[$networkName].Add($name)
        }
    }
    
    # Now build the dependency map
    foreach ($container in $containers) {
        $name = $container.Name.TrimStart('/')
        $links = [System.Collections.ArrayList]@()
        
        # Get container dependencies from NetworkMode
        if ($container.HostConfig.NetworkMode -match "^container:(.+)$") {
            [void]$links.Add($matches[1])
        }
        
        # Get dependencies from Links
        if ($container.HostConfig.Links) {
            $containerLinks = $container.HostConfig.Links | ForEach-Object {
                $_ -split ':' | Select-Object -First 1
            }
            foreach ($link in $containerLinks) {
                [void]$links.Add($link)
            }
        }
        
        # Get dependencies from DependsOn
        if ($container.Config.Labels.'com.docker.compose.depends_on') {
            $dependsOn = $container.Config.Labels.'com.docker.compose.depends_on' -split ','
            foreach ($dep in $dependsOn) {
                [void]$links.Add($dep.Trim())
            }
        }
        
        # Get dependencies from shared networks
        foreach ($network in $container.NetworkSettings.Networks.PSObject.Properties) {
            $networkName = $network.Name
            if ($networkName -ne 'bridge' -and $networkMap.ContainsKey($networkName)) {
                foreach ($networkContainer in $networkMap[$networkName]) {
                    if ($networkContainer -ne $name) {
                        [void]$links.Add($networkContainer)
                    }
                }
            }
        }
        
        $dependencyMap[$name] = $links | Select-Object -Unique
    }
    
    return $dependencyMap
}

function Get-ShutdownOrder {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$DependencyMap
    )
    
    $visited = @{}
    $shutdownOrder = [System.Collections.ArrayList]@()
    
    function Visit-Node {
        param($node)
        
        if ($visited[$node] -eq 1) {
            Write-Warning "Circular dependency detected at container: $node"
            return
        }
        
        if ($visited[$node] -eq 2) { return }
        
        $visited[$node] = 1
        foreach ($dep in $DependencyMap[$node]) {
            if ($DependencyMap.ContainsKey($dep)) {
                Visit-Node -node $dep
            }
        }
        $visited[$node] = 2
        [void]$shutdownOrder.Add($node)
    }
    
    foreach ($container in $DependencyMap.Keys) {
        if (-not $visited[$container]) {
            Visit-Node -node $container
        }
    }
    
    return $shutdownOrder
}

# Main script execution
try {
    Write-Host "Getting running containers and their dependencies..."
    $dependencies = Get-ContainerDependencies
    if ($dependencies.Count -eq 0) {
        Write-Host "No running containers found."
        exit 0
    }
    
    Write-Host "Calculating shutdown order..."
    $shutdownOrder = Get-ShutdownOrder -DependencyMap $dependencies
    
    Write-Host "Starting graceful shutdown in the following order:"
    $shutdownOrder | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    
    foreach ($container in $shutdownOrder) {
        Write-Host "Processing container: $container"
        
        # Show initial progress
        Show-Progress -containerName $container -status "Shutting down"
        
        # Send SIGTERM signal and wait for graceful shutdown
        docker stop --time=30 $container
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Warning: Failed to stop container $container gracefully"
            Show-Progress -containerName $container -status "Force stopping"
            docker kill $container
        }
    }
    
    Write-Host "`nAll containers have been stopped successfully."
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}