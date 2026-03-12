<#
.SYNOPSIS
    Silently removes predefined bloatware using Winget, with auto-elevation.
.DESCRIPTION
    Production-grade script that requires no user interaction. It checks for 
    admin privileges, attempts to auto-elevate if necessary, safeguards a list 
    of protected applications, and logs all actions.
#>

# Define the log file location
$LogPath = "C:\IT_Logs\BloatwareRemoval_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Ensure the log directory exists
$LogDir = Split-Path $LogPath
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

Function Write-Log {
    Param (
        [string]$Message, 
        [string]$Type="INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Type] $Message"
    # Suppress console output for true silence, strictly log to file
    Add-Content -Path $LogPath -Value $LogEntry
}

Write-Log "Starting automated bloatware removal..."

# =================================================================
# Improved Admin Check & Auto-Elevation
# =================================================================
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Log "Current session is not elevated. Attempting to restart as Administrator..." "WARN"
    
    try {
        # Relaunches the script hidden, bypassing execution policy
        Start-Process PowerShell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        
        # Exit the current unprivileged session successfully so it doesn't run the rest of the code
        exit 0 
    } catch {
        # If UAC is denied or fails to prompt silently
        Write-Log "Auto-elevation failed or was denied. Script cannot continue." "CRITICAL"
        exit 1
    }
} else {
    Write-Log "Confirmed: Script is running with Administrator privileges." "SUCCESS"
}
# =================================================================

# Verify Winget is accessible
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Log "Winget is not recognized on this system. Aborting." "CRITICAL"
    exit 1
}

# PROTECTED APPS: Explicitly skipped if encountered
$ProtectedApps = @(
    "7zip.7zip", "Famatech.RadminVPN", "ONLYOFFICE.DesktopEditors",
    "RARLab.WinRAR", "Adobe.Acrobat.Reader.64-bit", "CodecGuide.K-LiteCodecPack.Full",
    "AnyDesk.AnyDesk", "Intel.IntelDriverAndSupportAssistant",
    "Google.Chrome", "Mozilla.Firefox"
)

# TARGET BLOATWARE: Exact Winget IDs. You may add more, if needed.
$BloatwareList = @(
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.Clipchamp"
    "Microsoft.549981C3F5F10"
    "Microsoft.DevHome"
    "Microsoft.Getstarted"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Paint3D"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Teams"
    "Microsoft.Wallet"
    "Microsoft.WidgetsPlatformRuntime"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "McAfee.LiveSafe"
    "Lenovo.LenovoVantage"
    "Microsoft.BingSearch"
    "Clipchamp.Clipchamp"
    "Microsoft.WindowsAlarms"
    "Microsoft.Copilot"
    "Microsoft.Windows.DevHome"
    "MicrosoftCorporationII.MicrosoftFamily"
    "Microsoft.Edge.GameAssist"
    "Microsoft.GetHelp"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.Office.OneNote"
    "Microsoft.OutlookForWindows"
    "Microsoft.MSPaint"
    "Microsoft.PowerAutomateDesktop"
    "MicrosoftCorporationII.QuickAssist"
    "Microsoft.MicrosoftStickyNotes"
    "MicrosoftTeams"
    "MSTeams"
    "Microsoft.Todos"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.GamingApp"
)

foreach ($App in $BloatwareList) {
    # Defensive check
    if ($ProtectedApps -contains $App) {
        Write-Log "App $App is in the protected list. Skipping removal." "WARN"
        continue
    }

    Write-Log "Attempting to remove: $App"

    $Arguments = @(
        "uninstall", 
        "-e", 
        "--id", $App, 
        "-h", 
        "--accept-source-agreements"
    )

    try {
        $Process = Start-Process -FilePath "winget.exe" -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ExitCode = $Process.ExitCode

        if ($ExitCode -eq 0) {
            Write-Log "Successfully removed: $App" "SUCCESS"
        } 
        elseif ($ExitCode -eq -1978335189 -or $ExitCode -eq -1978335215) {
            Write-Log "$App is not installed on this system. Skipping." "INFO"
        }
        else {
            Write-Log "Failed to remove $App. Exit code: $ExitCode" "ERROR"
        }
    } catch {
        Write-Log "Exception occurred while trying to remove $App: $_" "ERROR"
    }
}

Write-Log "Bloatware removal process completed."
