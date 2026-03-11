<#
.SYNOPSIS
    Silently sets the Desktop and Lock Screen wallpapers system-wide.
.DESCRIPTION
    Copies a wallpaper image from the script's execution directory to a secure 
    system folder, then enforces it as the default for all users via Registry Policies.
#>

# Define the log file location
$LogPath = "C:\IT_Logs\WallpaperSetup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

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
    Add-Content -Path $LogPath -Value $LogEntry
}

Write-Log "Starting automated wallpaper provisioning..."

# =================================================================
# Admin Check & Auto-Elevation
# =================================================================
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Log "Current session is not elevated. Attempting to restart as Administrator..." "WARN"
    try {
        Start-Process PowerShell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit 0 
    } catch {
        Write-Log "Auto-elevation failed or was denied. Script cannot continue." "CRITICAL"
        exit 1
    }
} else {
    Write-Log "Confirmed: Script is running with Administrator privileges." "SUCCESS"
}
# =================================================================

# 1. Resolve Paths Dynamically
# Expects the image to be in the exact same folder as this script.
$ImageFileName = "Wallpaper.png"
$SourceImage = Join-Path -Path $PSScriptRoot -ChildPath $ImageFileName
$DestFolder = "C:\Windows\Web\Wallpaper\Custom"
$DestImage = Join-Path -Path $DestFolder -ChildPath $ImageFileName

# 2. Verify Source Image Exists
if (-not (Test-Path $SourceImage)) {
    Write-Log "Source image not found at $SourceImage. Ensure the image is packaged with the script." "CRITICAL"
    exit 1
}

# 3. Create Destination Directory & Copy File
try {
    if (-not (Test-Path $DestFolder)) {
        New-Item -ItemType Directory -Path $DestFolder -Force | Out-Null
        Write-Log "Created custom wallpaper directory at $DestFolder."
    }
    
    Copy-Item -Path $SourceImage -Destination $DestImage -Force
    Write-Log "Successfully copied wallpaper to $DestImage."
} catch {
    Write-Log "Failed to copy wallpaper file: $_" "ERROR"
    exit 1
}

# 4. Apply Desktop Wallpaper via Registry (All Users Policy)
try {
    $DesktopRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $DesktopRegPath)) {
        New-Item -Path $DesktopRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $DesktopRegPath -Name "Wallpaper" -Value $DestImage -Force
    Set-ItemProperty -Path $DesktopRegPath -Name "WallpaperStyle" -Value "2" -Force # 2 = Stretch/Fill
    Write-Log "Desktop wallpaper policy set successfully."
} catch {
    Write-Log "Failed to set Desktop wallpaper registry policy: $_" "ERROR"
}

# 5. Apply Lock Screen Wallpaper via Registry (Enterprise/Education Policy)
try {
    $LockScreenRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    if (-not (Test-Path $LockScreenRegPath)) {
        New-Item -Path $LockScreenRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $LockScreenRegPath -Name "LockScreenImage" -Value $DestImage -Force
    Write-Log "Lock screen wallpaper policy set successfully."
} catch {
    Write-Log "Failed to set Lock screen registry policy: $_" "ERROR"
}

# 6. Force Explorer to Refresh (Optional, best effort)
try {
    Write-Log "Attempting to refresh user interface settings..."
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
} catch {
    Write-Log "UI refresh command failed. Changes will apply on next logon." "WARN"
}

Write-Log "Wallpaper provisioning completed."
