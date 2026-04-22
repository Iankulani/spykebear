#!/usr/bin/env pwsh
# SPYKE BEAR - PowerShell Installation Script

param(
    [switch]$NoAdmin,
    [switch]$SkipDeps,
    [string]$InstallPath = "$env:USERPROFILE\.spykebear"
)

# Set console output
$Host.UI.RawUI.WindowTitle = "Spyke Bear Installer"

# Colors
$ORANGE = "`e[38;5;208m"
$GREEN = "`e[92m"
$RED = "`e[91m"
$YELLOW = "`e[93m"
$BLUE = "`e[94m"
$RESET = "`e[0m"

function Write-Banner {
    Write-Host "$ORANGE"
    @"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     ███████╗██████╗ ██╗   ██╗██╗  ██╗███████╗                ║
║     ██╔════╝██╔══██╗╚██╗ ██╔╝██║ ██╔╝██╔════╝                ║
║     ███████╗██████╔╝ ╚████╔╝ █████╔╝ █████╗                  ║
║     ╚════██║██╔═══╝   ╚██╔╝  ██╔═██╗ ██╔══╝                  ║
║     ███████║██║        ██║   ██║  ██╗███████╗                ║
║     ╚══════╝╚═╝        ╚═╝   ╚═╝  ╚═╝╚══════╝                ║
║                                                               ║
║              ██████╗ ███████╗ █████╗ ██████╗                 ║
║              ██╔══██╗██╔════╝██╔══██╗██╔══██╗                ║
║              ██████╔╝█████╗  ███████║██████╔╝                ║
║              ██╔══██╗██╔══╝  ██╔══██║██╔══██╗                ║
║              ██████╔╝███████╗██║  ██║██║  ██║                ║
║              ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝                ║
║                                                               ║
║                  CYBERSECURITY COMMAND CENTER                 ║
║                         v1.0.0                                ║
╚═══════════════════════════════════════════════════════════════╝
"@
    Write-Host "$RESET"
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-PythonDeps {
    Write-Host "$YELLOW[*] Installing Python dependencies...$RESET"
    
    $packages = @(
        "requests", "psutil", "cryptography", "paramiko", "scapy",
        "python-whois", "qrcode", "pyshorteners", "colorama",
        "flask", "flask-socketio", "python-socketio", "eventlet",
        "sqlalchemy", "discord.py", "telethon", "slack-sdk",
        "selenium", "webdriver-manager", "dnspython", "netifaces",
        "geoip2", "beautifulsoup4", "lxml"
    )
    
    foreach ($pkg in $packages) {
        Write-Host "  Installing $pkg..."
        pip install $pkg --quiet
    }
    
    Write-Host "$GREEN[✓] Python dependencies installed$RESET"
}

function Install-SystemTools {
    Write-Host "$YELLOW[*] Installing system tools...$RESET"
    
    # Check for winget (Windows 11/10)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $tools = @(
            "Nmap.Nmap", "Git.Git", "Python.Python.3.11",
            "WiresharkFoundation.Wireshark", "GnuWin32.Make"
        )
        foreach ($tool in $tools) {
            Write-Host "  Installing $tool..."
            winget install $tool --silent --accept-package-agreements
        }
    }
    else {
        Write-Host "$YELLOW[!] winget not found. Please install manually:$RESET"
        Write-Host "  - Nmap: https://nmap.org/download.html"
        Write-Host "  - Git: https://git-scm.com/download/win"
        Write-Host "  - Wireshark: https://www.wireshark.org/download.html"
    }
    
    Write-Host "$GREEN[✓] System tools installation initiated$RESET"
}

function Setup-Directories {
    Write-Host "$YELLOW[*] Creating directories...$RESET"
    
    $dirs = @(
        "$InstallPath\payloads", "$InstallPath\workspaces", "$InstallPath\scans",
        "$InstallPath\nikto_results", "$InstallPath\whatsapp_session", "$InstallPath\phishing_pages",
        "$InstallPath\reports", "$InstallPath\traffic_logs", "$InstallPath\phishing_templates",
        "$InstallPath\captured_credentials", "$InstallPath\ssh_keys", "$InstallPath\ssh_logs",
        "$InstallPath\time_history", "$InstallPath\wordlists", "$InstallPath\web_static"
    )
    
    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    
    Write-Host "$GREEN[✓] Directories created$RESET"
}

function Create-Launcher {
    Write-Host "$YELLOW[*] Creating launcher scripts...$RESET"
    
    # Batch launcher
    $batchContent = @"
@echo off
title Spyke Bear Command Center
cd /d "$InstallPath"
python spykebear.py %*
"@
    $batchPath = "$env:USERPROFILE\Desktop\SpykeBear.bat"
    $batchContent | Out-File -FilePath $batchPath -Encoding ASCII
    
    # PowerShell launcher
    $psContent = @"
Write-Host "🐻 Starting Spyke Bear..." -ForegroundColor Cyan
Set-Location "$InstallPath"
python spykebear.py
"@
    $psPath = "$env:USERPROFILE\Desktop\SpykeBear.ps1"
    $psContent | Out-File -FilePath $psPath -Encoding UTF8
    
    Write-Host "$GREEN[✓] Launchers created on Desktop$RESET"
}

function Create-RegistryEntry {
    Write-Host "$YELLOW[*] Adding to PATH...$RESET"
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$InstallPath*") {
        $newPath = "$currentPath;$InstallPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "$GREEN[✓] Added to PATH$RESET"
    }
}

function Show-Completion {
    Write-Host "$GREEN"
    @"
╔═══════════════════════════════════════════════════════════════╗
║         SPYKE BEAR Installation Complete!                    ║
╚═══════════════════════════════════════════════════════════════╝
"@
    Write-Host "$RESET"
    Write-Host "$YELLOW📁 Installation Directory: $InstallPath$RESET"
    Write-Host "$YELLOW🚀 Launch: Desktop\SpykeBear.bat$RESET"
    Write-Host "$YELLOW🚀 Or: python $InstallPath\spykebear.py$RESET"
    Write-Host "$YELLOW🌐 Web Interface: http://localhost:8080$RESET"
    Write-Host "$YELLOW📚 Help: Type 'help' in the console$RESET"
    Write-Host ""
    Write-Host "$BLUE⚠️  For full functionality (packet capture, spoofing):$RESET"
    Write-Host "$BLUE   Run PowerShell/Terminal as Administrator$RESET"
    Write-Host ""
    Write-Host "$ORANGE🐻 Ready to secure!$RESET"
}

function Main {
    Write-Banner
    Write-Host "$BLUE[*] Starting Spyke Bear Installation...$RESET`n"
    
    # Check admin
    if (-not $NoAdmin -and -not (Test-Admin)) {
        Write-Host "$YELLOW[!] Not running as Administrator$RESET"
        Write-Host "$YELLOW[!] Some features require admin privileges$RESET"
        $response = Read-Host "Continue without Admin? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "$RED[!] Please run as Administrator$RESET"
            exit 1
        }
    }
    
    # Check Python
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Host "$RED[!] Python not found$RESET"
        Write-Host "$YELLOW[*] Downloading Python...$RESET"
        $pythonUrl = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe"
        Invoke-WebRequest -Uri $pythonUrl -OutFile "$env:TEMP\python-installer.exe"
        Start-Process "$env:TEMP\python-installer.exe" -Wait
    }
    
    $pythonVersion = & python --version
    Write-Host "$GREEN[✓] $pythonVersion found$RESET"
    
    # Upgrade pip
    Write-Host "$YELLOW[*] Upgrading pip...$RESET"
    python -m pip install --upgrade pip
    
    # Install dependencies
    if (-not $SkipDeps) {
        Install-PythonDeps
        Install-SystemTools
    }
    
    # Setup
    Setup-Directories
    Create-Launcher
    Create-RegistryEntry
    
    # Copy the main script
    if (Test-Path "spykebear.py") {
        Copy-Item "spykebear.py" -Destination "$InstallPath\" -Force
    }
    
    Show-Completion
}

# Run main function
Main