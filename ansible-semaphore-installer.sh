#!/bin/bash

# Ansible & Semaphore Installer
# Made by Sunil Kumar
# Website: https://techconvergence.dev
# 
# Automated installation script for Ansible and Semaphore on Debian/Ubuntu systems

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root. Please run with sudo or as root user."
        exit 1
    fi
    log_info "Running as root - proceeding with installation."
}

check_system() {
    log_info "Checking system compatibility..."
    
    if ! command -v apt &> /dev/null; then
        log_error "This script is designed for Debian/Ubuntu systems with apt package manager."
        exit 1
    fi
    
    if [[ $EUID -ne 0 ]] && ! command -v sudo &> /dev/null; then
        log_error "sudo is required but not installed."
        exit 1
    fi
    
    log_success "System compatibility check passed."
}

update_system() {
    log_info "Updating system packages..."
    apt update && apt upgrade -y
    log_success "System packages updated."
}

install_ansible() {
    log_info "Installing Ansible..."
    
    apt install -y software-properties-common
    add-apt-repository --yes --update ppa:ansible/ansible
    apt install -y ansible
    
    if ansible --version &> /dev/null; then
        log_success "Ansible installed successfully."
        ansible --version
    else
        log_error "Ansible installation failed."
        exit 1
    fi
}

create_semaphore_user() {
    log_info "Creating Semaphore user..."
    
    if id "semaphore" &>/dev/null; then
        log_warning "User 'semaphore' already exists."
    else
        adduser --system --group --home /home/semaphore semaphore
        log_success "Semaphore user created."
    fi
}

install_mariadb() {
    log_info "Installing MariaDB server..."
    
    apt install -y mariadb-server
    systemctl start mariadb
    systemctl enable mariadb
    
    log_success "MariaDB installed and started."
    
    echo
    log_info "Database configuration required..."
    echo "Please run the following command manually after the script completes:"
    echo "mysql_secure_installation"
    echo
    
    DB_PASSWORD=$(openssl rand -base64 32)
    
    log_info "Creating Semaphore database and user..."
    
    mariadb -e "
    CREATE DATABASE IF NOT EXISTS semaphore_db;
    DROP USER IF EXISTS 'semaphore_user'@'localhost';
    CREATE USER 'semaphore_user'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON semaphore_db.* TO 'semaphore_user'@'localhost';
    FLUSH PRIVILEGES;
    "
    
    echo "Database Password: ${DB_PASSWORD}" | tee /home/semaphore/db_credentials.txt
    chown semaphore:semaphore /home/semaphore/db_credentials.txt
    chmod 600 /home/semaphore/db_credentials.txt
    
    log_success "Database and user created. Password saved to /home/semaphore/db_credentials.txt"
}

get_latest_semaphore_version() {
    log_info "Fetching latest Semaphore version..."
    
    LATEST_VERSION=$(curl -s https://api.github.com/repos/semaphoreui/semaphore/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to fetch latest Semaphore version."
        exit 1
    fi
    
    log_info "Latest Semaphore version: ${LATEST_VERSION}"
}

install_semaphore() {
    log_info "Installing Semaphore..."
    
    get_latest_semaphore_version
    
    DOWNLOAD_URL="https://github.com/semaphoreui/semaphore/releases/download/${LATEST_VERSION}/semaphore_${LATEST_VERSION#v}_linux_amd64.deb"
    
    log_info "Downloading Semaphore from: ${DOWNLOAD_URL}"
    
    cd /tmp
    wget "${DOWNLOAD_URL}" -O semaphore.deb
    
    dpkg -i semaphore.deb
    apt-get install -f -y
    
    log_success "Semaphore installed successfully."
}

configure_semaphore() {
    log_info "Configuring Semaphore..."
    
    mkdir -p /etc/semaphore
    
    DB_PASSWORD=$(cat /home/semaphore/db_credentials.txt | cut -d' ' -f3)
    
    tee /etc/semaphore/config.json > /dev/null <<EOF
{
  "mysql": {
    "host": "127.0.0.1:3306",
    "user": "semaphore_user",
    "pass": "${DB_PASSWORD}",
    "name": "semaphore_db"
  },
  "bolt": {
    "host": "",
    "user": "",
    "pass": "",
    "name": ""
  },
  "postgres": {
    "host": "",
    "user": "",
    "pass": "",
    "name": "",
    "options": {}
  },
  "dialect": "mysql",
  "port": ":3000",
  "interface": "",
  "tmp_path": "/tmp/semaphore",
  "cookie_hash": "$(openssl rand -base64 32)",
  "cookie_encryption": "$(openssl rand -base64 32)",
  "access_key_encryption": "$(openssl rand -base64 32)",
  "email_sender": "",
  "email_host": "",
  "email_port": "",
  "web_host": "",
  "ldap_bind_dn": "",
  "ldap_bind_password": "",
  "ldap_server": "",
  "ldap_searchdn": "",
  "ldap_searchfilter": "",
  "ldap_mappings": {
    "dn": "",
    "mail": "",
    "uid": "",
    "cn": ""
  },
  "telegram_chat": "",
  "telegram_token": "",
  "slack_url": "",
  "max_parallel_tasks": 10
}
EOF
    
    chown -R semaphore:semaphore /etc/semaphore
    chmod 600 /etc/semaphore/config.json
    
    mkdir -p /tmp/semaphore
    chown semaphore:semaphore /tmp/semaphore
    
    log_success "Semaphore configuration created."
}

create_admin_user() {
    log_info "Creating Semaphore admin user..."
    
    log_info "Running database migration..."
    sudo -u semaphore semaphore migrate --config /etc/semaphore/config.json
    
    log_info "Creating admin user..."
    sudo -u semaphore semaphore user add \
        --admin \
        --login Sunil \
        --email admin@localhost \
        --name "Sunil Kumar" \
        --password "technologia" \
        --config /etc/semaphore/config.json
    
    echo "Admin Username: Sunil" | tee /home/semaphore/admin_credentials.txt
    echo "Admin Password: technologia" | tee -a /home/semaphore/admin_credentials.txt
    chown semaphore:semaphore /home/semaphore/admin_credentials.txt
    chmod 600 /home/semaphore/admin_credentials.txt
    
    log_success "Admin user created. Credentials saved to /home/semaphore/admin_credentials.txt"
}

create_systemd_service() {
    log_info "Creating Systemd service..."
    
    tee /etc/systemd/system/semaphore.service > /dev/null <<EOF
[Unit]
Description=Semaphore UI
Documentation=https://docs.semaphoreui.com/
Wants=network-online.target
After=network-online.target mariadb.service
ConditionPathExists=/usr/bin/semaphore
ConditionPathExists=/etc/semaphore/config.json

[Service]
ExecStart=/usr/bin/semaphore server --config /etc/semaphore/config.json
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10s
User=semaphore
Group=semaphore
WorkingDirectory=/home/semaphore

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable semaphore.service
    
    log_success "Systemd service created and enabled."
}

start_services() {
    log_info "Starting services..."
    
    systemctl start mariadb
    systemctl start semaphore.service
    
    if systemctl is-active --quiet semaphore.service; then
        log_success "Semaphore service started successfully."
    else
        log_error "Failed to start Semaphore service."
        log_info "Checking service status:"
        systemctl status semaphore.service
        exit 1
    fi
}

display_final_info() {
    ADMIN_USERNAME=$(grep "Admin Username" /home/semaphore/admin_credentials.txt | cut -d' ' -f3)
    ADMIN_PASSWORD=$(grep "Admin Password" /home/semaphore/admin_credentials.txt | cut -d' ' -f3)
    
    echo
    log_success "Installation completed successfully!"
    echo
    echo "=========================================="
    echo "           WELCOME TO SEMAPHORE!"
    echo "=========================================="
    echo "Made by Sunil Kumar"
    echo "https://techconvergence.dev"
    echo "=========================================="
    echo
    echo "=== SEMAPHORE ACCESS INFORMATION ==="
    echo
    echo "🌐 Web Interface:"
    echo "   URL: http://$(hostname -I | awk '{print $1}'):3000"
    echo "   Alternative: http://localhost:3000"
    echo
    echo "🔐 Admin Login Credentials:"
    echo "   Username: ${ADMIN_USERNAME}"
    echo "   Password: ${ADMIN_PASSWORD}"
    echo
    echo "⚠️  IMPORTANT: Change these credentials after first login!"
    echo
    echo "=== CONFIGURATION FILES ==="
    echo
    echo "📁 Database credentials: /home/semaphore/db_credentials.txt"
    echo "🔑 Admin credentials: /home/semaphore/admin_credentials.txt"
    echo "⚙️  Configuration file: /etc/semaphore/config.json"
    echo
    echo "=== SERVICE MANAGEMENT ==="
    echo
    echo "▶️  Start:   systemctl start semaphore.service"
    echo "⏹️  Stop:    systemctl stop semaphore.service"
    echo "🔄 Restart: systemctl restart semaphore.service"
    echo "📊 Status:  systemctl status semaphore.service"
    echo
    echo "📝 View Logs: journalctl -u semaphore.service -f"
    echo
    echo "=== SECURITY RECOMMENDATIONS ==="
    echo
    echo "🔒 Run 'mysql_secure_installation' to secure MariaDB"
    echo "🛡️  Configure firewall to restrict access to port 3000"
    echo "🔑 Change admin credentials after first login"
    echo "🔐 Consider setting up SSL/TLS for production use"
    echo "🌐 Restrict network access to trusted IPs only"
    echo
    echo "=== QUICK START GUIDE ==="
    echo
    echo "1. 🌐 Open your browser and go to http://$(hostname -I | awk '{print $1}'):3000"
    echo "2. 🔑 Login with username: ${ADMIN_USERNAME}, password: ${ADMIN_PASSWORD}"
    echo "3. ⚙️  Change your admin password immediately"
    echo "4. 📂 Create your first project"
    echo "5. 🔗 Connect your Ansible playbook repository"
    echo "6. 🚀 Start automating with Semaphore!"
    echo
    echo "=== NEED HELP? ==="
    echo
    echo "📚 Documentation: https://docs.semaphoreui.com/"
    echo "🌐 Website: https://techconvergence.dev"
    echo "💬 For support, visit the documentation or create an issue"
    echo
    echo "=========================================="
    echo "    Thank you for using this installer!"
    echo "    Happy Automating! 🚀"
    echo "=========================================="
    echo
}

main() {
    echo "=========================================="
    echo "    Ansible & Semaphore Installer"
    echo "=========================================="
    echo "Made by Sunil Kumar"
    echo "https://techconvergence.dev"
    echo "=========================================="
    echo
    
    check_root
    check_system
    update_system
    install_ansible
    create_semaphore_user
    install_mariadb
    install_semaphore
    configure_semaphore
    create_admin_user
    create_systemd_service
    start_services
    display_final_info
}

main "$@"
