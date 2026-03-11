<#
.SYNOPSIS
    Installs a standard set of applications silently using Winget.
.DESCRIPTION
    Automates software installation for new machine setups. Includes centralized 
    logging, silent installation flags, and basic error handling for a production environment.
#>

# Define the log file location (creates a unique log per run)
$LogPath = "C:\IT_Logs\AppInstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Array of Application IDs (Makes adding/removing apps much cleaner)
$AppList = @(
    # Tools
    "7zip.7zip"
    "Famatech.RadminVPN"
    "ONLYOFFICE.DesktopEditors"
    "RARLab.WinRAR"
    "Adobe.Acrobat.Reader.64-bit"
    "CodecGuide.K-LiteCodecPack.Full"
    "AnyDesk.AnyDesk"
    "Intel.IntelDriverAndSupportAssistant"
    # Browsers
    "Google.Chrome"
    "Mozilla.Firefox"
)

# Ensure the log directory exists
$LogDir = Split-Path $LogPath
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Custom Logging Function
Function Write-Log {
    Param (
        [string]$Message, 
        [string]$Type="INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Type] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogPath -Value $LogEntry
}

Write-Log "Starting automated software installation..."

# Verify Winget is accessible
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Log "Winget is not recognized on this system. Aborting." "CRITICAL"
    exit 1
}

# Iterate through the application list
foreach ($App in $AppList) {
    Write-Log "Attempting to install: $App"

    # -e: exact match for ID
    # -h: hidden/silent installation
    # --accept...: bypasses all prompts for a true zero-touch install
    $Arguments = @(
        "install", 
        "-e", 
        "--id", $App, 
        "-h", 
        "--accept-package-agreements", 
        "--accept-source-agreements"
    )

    try {
        # Execute Winget and capture the exit code
        $Process = Start-Process -FilePath "winget.exe" -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ExitCode = $Process.ExitCode

        if ($ExitCode -eq 0) {
            Write-Log "Successfully installed: $App" "SUCCESS"
        } 
        elseif ($ExitCode -eq -1978335189) {
            # Winget error code for "Already Installed"
            Write-Log "$App is already installed. Skipping." "INFO"
        }
        else {
            Write-Log "Failed to install $App. Exit code: $ExitCode" "ERROR"
        }
    } catch {
        Write-Log "Exception occurred while trying to install $App: $_" "ERROR"
    }
}

Write-Log "Software installation process completed. Please review the log for any errors."
