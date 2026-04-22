#!/bin/bash
# SPYKE BEAR - Installation Script for Linux/macOS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[38;5;208m'
NC='\033[0m'

print_banner() {
    echo -e "${ORANGE}"
    cat << "EOF"
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
EOF
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}[!] Some features require root privileges (spoofing, packet capture)${NC}"
        echo -e "${YELLOW}[!] Continue without root? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}[!] Please run with sudo for full functionality${NC}"
            exit 1
        fi
    fi
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [[ -f /etc/debian_version ]]; then
            DISTRO="debian"
            PKG_MANAGER="apt-get"
            PKG_UPDATE="apt-get update"
            PKG_INSTALL="apt-get install -y"
        elif [[ -f /etc/redhat-release ]]; then
            DISTRO="redhat"
            PKG_MANAGER="yum"
            PKG_UPDATE="yum check-update"
            PKG_INSTALL="yum install -y"
        elif [[ -f /etc/arch-release ]]; then
            DISTRO="arch"
            PKG_MANAGER="pacman"
            PKG_UPDATE="pacman -Sy"
            PKG_INSTALL="pacman -S --noconfirm"
        else
            DISTRO="unknown"
            PKG_MANAGER=""
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if command -v brew &> /dev/null; then
            PKG_MANAGER="brew"
            PKG_INSTALL="brew install"
        else
            echo -e "${RED}[!] Homebrew required for macOS installation${NC}"
            echo -e "${YELLOW}[!] Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
            exit 1
        fi
    else
        echo -e "${RED}[!] Unsupported OS${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] Detected: $OS ($DISTRO)${NC}"
}

install_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}[*] Installing Python 3...${NC}"
        case $PKG_MANAGER in
            apt-get) $PKG_INSTALL python3 python3-pip python3-venv ;;
            yum) $PKG_INSTALL python3 python3-pip ;;
            pacman) $PKG_INSTALL python python-pip ;;
            brew) $PKG_INSTALL python3 ;;
        esac
    fi
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}[✓] Python $PYTHON_VERSION${NC}"
}

install_system_deps() {
    echo -e "${YELLOW}[*] Installing system dependencies...${NC}"
    
    case $OS in
        linux)
            $PKG_UPDATE
            $PKG_INSTALL nmap tcpdump net-tools iproute2 curl wget \
                netcat-openbsd whois dnsutils hping3 macchanger \
                arp-scan dsniff tcpreplay ngrep build-essential \
                libpcap-dev libssl-dev python3-dev chromium \
                chromium-driver git
            ;;
        macos)
            $PKG_INSTALL nmap tcpdump net-tools coreutils curl wget \
                netcat whois bind hping3 macchanger arp-scan \
                dsniff tcpreplay ngrep openssl
            ;;
    esac
    echo -e "${GREEN}[✓] System dependencies installed${NC}"
}

setup_virtualenv() {
    echo -e "${YELLOW}[*] Setting up Python virtual environment...${NC}"
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip setuptools wheel
    echo -e "${GREEN}[✓] Virtual environment created${NC}"
}

install_python_deps() {
    echo -e "${YELLOW}[*] Installing Python dependencies...${NC}"
    
    if [[ -f requirements.txt ]]; then
        pip install -r requirements.txt
    else
        pip install requests psutil cryptography paramiko scapy \
            python-whois qrcode pyshorteners colorama flask \
            flask-socketio python-socketio eventlet sqlalchemy \
            discord.py telethon slack-sdk selenium webdriver-manager
    fi
    
    echo -e "${GREEN}[✓] Python dependencies installed${NC}"
}

setup_directories() {
    echo -e "${YELLOW}[*] Creating directories...${NC}"
    mkdir -p ~/.spykebear/{payloads,workspaces,scans,nikto_results,whatsapp_session,phishing_pages,reports,traffic_logs,phishing_templates,captured_credentials,ssh_keys,ssh_logs,time_history,wordlists,web_static}
    echo -e "${GREEN}[✓] Directories created${NC}"
}

create_launcher() {
    cat > /usr/local/bin/spykebear << EOF
#!/bin/bash
cd "$(pwd)"
source venv/bin/activate
python3 spykebear.py "\$@"
EOF
    chmod +x /usr/local/bin/spykebear
    echo -e "${GREEN}[✓] Launcher created: spykebear${NC}"
}

create_desktop_entry() {
    if [[ "$OS" == "linux" ]]; then
        cat > ~/.local/share/applications/spykebear.desktop << EOF
[Desktop Entry]
Name=Spyke Bear
Comment=Cybersecurity Command Center
Exec=/usr/local/bin/spykebear
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Network;Security;
EOF
        echo -e "${GREEN}[✓] Desktop entry created${NC}"
    fi
}

show_completion() {
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ SPYKE BEAR Installation Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📁 Installation Directory: $(pwd)${NC}"
    echo -e "${YELLOW}🚀 Launch: ${GREEN}spykebear${NC} or ${GREEN}python3 spykebear.py${NC}"
    echo -e "${YELLOW}🌐 Web Interface: ${GREEN}http://localhost:8080${NC}"
    echo -e "${YELLOW}📚 Help: ${GREEN}spykebear --help${NC}"
    echo -e "\n${BLUE}⚠️  For full functionality (spoofing, packet capture), run with:${NC}"
    echo -e "${GREEN}   sudo spykebear${NC}"
    echo -e "\n${ORANGE}🐻 Ready to secure!${NC}"
}

main() {
    print_banner
    echo -e "${BLUE}[*] Starting Spyke Bear Installation...${NC}\n"
    
    check_root
    detect_os
    install_python
    install_system_deps
    setup_virtualenv
    install_python_deps
    setup_directories
    create_launcher
    create_desktop_entry
    show_completion
}

main "$@"