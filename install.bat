@echo off
title Spyke Bear Installer
setlocal enabledelayedexpansion

:: Colors for Windows
color 0E

echo.
echo [38;5;208m╔═══════════════════════════════════════════════════════════════╗[0m
echo [38;5;208m║                                                               ║[0m
echo [38;5;208m║     ███████╗██████╗ ██╗   ██╗██╗  ██╗███████╗                ║[0m
echo [38;5;208m║     ██╔════╝██╔══██╗╚██╗ ██╔╝██║ ██╔╝██╔════╝                ║[0m
echo [38;5;208m║     ███████╗██████╔╝ ╚████╔╝ █████╔╝ █████╗                  ║[0m
echo [38;5;208m║     ╚════██║██╔═══╝   ╚██╔╝  ██╔═██╗ ██╔══╝                  ║[0m
echo [38;5;208m║     ███████║██║        ██║   ██║  ██╗███████╗                ║[0m
echo [38;5;208m║     ╚══════╝╚═╝        ╚═╝   ╚═╝  ╚═╝╚══════╝                ║[0m
echo [38;5;208m║                                                               ║[0m
echo [38;5;208m║              ██████╗ ███████╗ █████╗ ██████╗                 ║[0m
echo [38;5;208m║              ██╔══██╗██╔════╝██╔══██╗██╔══██╗                ║[0m
echo [38;5;208m║              ██████╔╝█████╗  ███████║██████╔╝                ║[0m
echo [38;5;208m║              ██╔══██╗██╔══╝  ██╔══██║██╔══██╗                ║[0m
echo [38;5;208m║              ██████╔╝███████╗██║  ██║██║  ██║                ║[0m
echo [38;5;208m║              ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝                ║[0m
echo [38;5;208m║                                                               ║[0m
echo [38;5;208m║                  CYBERSECURITY COMMAND CENTER                 ║[0m
echo [38;5;208m║                         v1.0.0                                ║[0m
echo [38;5;208m╚═══════════════════════════════════════════════════════════════╝[0m
echo.

echo [94m[*] Starting Spyke Bear Installation for Windows...[0m
echo.

:: Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [93m[!] Not running as Administrator[0m
    echo [93m[!] Some features require Administrator privileges[0m
    echo [93m[!] Continue without Admin? (Y/N)[0m
    choice /n /c YN
    if errorlevel 2 exit /b
)

:: Check Python
where python >nul 2>&1
if %errorLevel% neq 0 (
    echo [91m[!] Python not found[0m
    echo [93m[*] Downloading Python installer...[0m
    curl -o python_installer.exe https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe
    echo [93m[*] Please install Python with 'Add to PATH' option[0m
    start python_installer.exe
    pause
    exit /b
)

:: Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [92m[✓] Python %PYTHON_VERSION% found[0m

:: Upgrade pip
echo [93m[*] Upgrading pip...[0m
python -m pip install --upgrade pip

:: Install Python dependencies
echo [93m[*] Installing Python dependencies...[0m
pip install requests psutil cryptography paramiko scapy python-whois qrcode pyshorteners colorama flask flask-socketio python-socketio eventlet sqlalchemy discord.py telethon slack-sdk selenium webdriver-manager dnspython netifaces geoip2 beautifulsoup4 lxml

:: Create directories
echo [93m[*] Creating directories...[0m
if not exist "%USERPROFILE%\.spykebear" mkdir "%USERPROFILE%\.spykebear"
cd /d "%USERPROFILE%\.spykebear"
mkdir payloads workspaces scans nikto_results whatsapp_session phishing_pages reports traffic_logs phishing_templates captured_credentials ssh_keys ssh_logs time_history wordlists web_static 2>nul

:: Download Nmap for Windows
echo [93m[*] Checking Nmap...[0m
where nmap >nul 2>&1
if %errorLevel% neq 0 (
    echo [93m[*] Downloading Nmap...[0m
    curl -o nmap-setup.exe https://nmap.org/dist/nmap-7.94-setup.exe
    echo [93m[*] Please install Nmap (add to PATH)[0m
    start nmap-setup.exe
)

:: Create launcher script
echo [93m[*] Creating launcher...[0m
(
echo @echo off
echo cd /d "%USERPROFILE%\.spykebear"
echo python spykebear.py %%*
) > "%USERPROFILE%\Desktop\SpykeBear.bat"

:: Create start menu shortcut
echo [93m[*] Creating start menu shortcut...[0m
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\SpykeBear.lnk'); $Shortcut.TargetPath = 'cmd.exe'; $Shortcut.Arguments = '/c cd /d %USERPROFILE%\.spykebear && python spykebear.py'; $Shortcut.Save()"

echo.
echo [92m╔═══════════════════════════════════════════════════════════════╗[0m
echo [92m║         SPYKE BEAR Installation Complete!                    ║[0m
echo [92m╚═══════════════════════════════════════════════════════════════╝[0m
echo.
echo [93m📁 Installation Directory: %USERPROFILE%\.spykebear[0m
echo [93m🚀 Launch: Desktop\SpykeBear.bat[0m
echo [93m🌐 Web Interface: http://localhost:8080[0m
echo.
echo [38;5;208m🐻 Ready to secure![0m
echo.
pause