function Initialize-Logging {
    param (
        [string]$LogPath = ".\logs",
        [string]$LogFile = "docker-graceful-shutdown.log"
    )
    
    # Create log directory if it doesn't exist
    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath | Out-Null
    }
    
    # Set global log file path
    $script:LogFilePath = Join-Path $LogPath $LogFile
    
    # Initialize log file with header
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $header = @"
========================================
Docker Graceful Shutdown Log
Started at: $timestamp
========================================

"@
    $header | Out-File -FilePath $script:LogFilePath -Encoding utf8
    
    Write-Host "Logging initialized. Log file: $script:LogFilePath"
}

function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'DEBUG')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    $logMessage | Out-File -FilePath $script:LogFilePath -Append -Encoding utf8
    
    # Also write to console with appropriate color
    switch ($Level) {
        'ERROR' { 
            Write-Host $logMessage -ForegroundColor Red 
        }
        'WARNING' { 
            Write-Host $logMessage -ForegroundColor Yellow 
        }
        'DEBUG' { 
            if ($VerbosePreference -eq 'Continue') {
                Write-Host $logMessage -ForegroundColor Gray 
            }
        }
        default { 
            Write-Host $logMessage -ForegroundColor Green 
        }
    }
}

function Write-ContainerOperation {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('START', 'STOP', 'REMOVE')]
        [string]$Operation,
        
        [string]$Status = 'SUCCESS',
        
        [string]$ErrorMessage
    )
    
    $message = "Container [$ContainerName] - Operation: $Operation - Status: $Status"
    if ($ErrorMessage) {
        $message += " - Error: $ErrorMessage"
        Write-Log -Message $message -Level 'ERROR'
    } else {
        Write-Log -Message $message -Level 'INFO'
    }
}

function Write-DependencyInfo {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Dependencies
    )
    
    Write-Log -Message "Container Dependencies:" -Level 'INFO'
    foreach ($container in $Dependencies.Keys) {
        $deps = $Dependencies[$container] -join ', '
        Write-Log -Message "  $container -> [$deps]" -Level 'DEBUG'
    }
}

Export-ModuleMember -Function Initialize-Logging, Write-Log, Write-ContainerOperation, Write-DependencyInfo
