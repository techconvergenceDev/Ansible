# Ansible Semaphore Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-blue.svg)](https://github.com/techconvergenceDev/Ansible)

Automated installation script for Ansible and Semaphore on Debian/Ubuntu systems.

**Made by Sunil Kumar** | [TechConvergence.dev](https://techconvergence.dev)

## 🚀 Quick Start

```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/techconvergenceDev/Ansible/main/ansible-semaphore-installer.sh | bash
```

Or download first:
```bash
wget https://raw.githubusercontent.com/techconvergenceDev/Ansible/main/ansible-semaphore-installer.sh
chmod +x ansible-semaphore-installer.sh
bash ansible-semaphore-installer.sh
```

## ✨ Features

- **🎯 Complete Automation**: One-command installation of both Ansible and Semaphore
- **📦 Latest Versions**: Automatically downloads the latest Semaphore release from GitHub
- **🔐 Secure Setup**: Random database passwords and proper user permissions
- **⚙️ Service Integration**: Full systemd service configuration with auto-startup
- **🎨 User-Friendly**: Color-coded output and comprehensive welcome screen
- **📚 Documentation**: Built-in help and security recommendations

## 📋 Requirements

- **OS**: Ubuntu 18.04+ or Debian 10+
- **Access**: Root privileges (run as root or with sudo)
- **Network**: Internet connection for downloads
- **Architecture**: x86_64 (amd64)

## 🔧 What Gets Installed

### Ansible
- ✅ Latest version from official PPA
- ✅ All required dependencies and tools

### Semaphore UI
- ✅ Latest release from [semaphoreui/semaphore](https://github.com/semaphoreui/semaphore)
- ✅ MariaDB database backend with secure configuration
- ✅ Systemd service for automatic startup
- ✅ Web interface accessible on port 3000

### Database & Security
- ✅ MariaDB server with dedicated database
- ✅ Secure user with random password generation
- ✅ Proper file permissions and ownership

## 🌐 Access Information

After installation, access Semaphore at:
- **URL**: `http://your-server-ip:3000`
- **Username**: `Sunil`
- **Password**: `technologia`

⚠️ **Change these credentials immediately after first login!**

## 📂 File Locations

| Item | Location |
|------|----------|
| Configuration | `/etc/semaphore/config.json` |
| Service file | `/etc/systemd/system/semaphore.service` |
| Database credentials | `/home/semaphore/db_credentials.txt` |
| Admin credentials | `/home/semaphore/admin_credentials.txt` |
| Logs | `journalctl -u semaphore.service` |

## 🛠️ Service Management

```bash
# Start Semaphore
systemctl start semaphore.service

# Stop Semaphore
systemctl stop semaphore.service

# Restart Semaphore
systemctl restart semaphore.service

# Check status
systemctl status semaphore.service

# View logs
journalctl -u semaphore.service -f
```

## 🔒 Security Recommendations

1. **🔐 Secure Database**: Run `mysql_secure_installation`
2. **🛡️ Firewall**: Configure firewall to restrict port 3000
3. **🔑 Change Credentials**: Update admin password after first login
4. **🌐 SSL/TLS**: Set up HTTPS for production environments
5. **📍 Network Access**: Restrict to trusted IP addresses only

## 🐛 Troubleshooting

### Service Won't Start
```bash
# Check service status
systemctl status semaphore.service

# View detailed logs
journalctl -u semaphore.service --no-pager

# Check configuration
sudo -u semaphore semaphore server --config /etc/semaphore/config.json
```

### Database Connection Issues
```bash
# Verify MariaDB is running
systemctl status mariadb

# Check database credentials
cat /home/semaphore/db_credentials.txt

# Test database connection
mysql -u semaphore_user -p semaphore_db
```

### Port 3000 Not Accessible
```bash
# Check firewall settings
ufw status
iptables -L

# Verify service is listening
netstat -tlnp | grep 3000
```

## 📁 Repository Structure

```
Ansible/
├── ansible-semaphore-installer.sh    # Main installation script
├── README.md                         # This file
├── LICENSE                          # MIT License
├── CONTRIBUTING.md                  # Contribution guidelines
├── SECURITY.md                      # Security policy
├── CHANGELOG.md                     # Version history
└── .gitignore                       # Git ignore file
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Support

For issues and questions:
- 🐛 [Open an issue](https://github.com/techconvergenceDev/Ansible/issues) on GitHub
- 📚 Check the [Semaphore documentation](https://docs.semaphoreui.com/)
- 📖 Review the [Ansible documentation](https://docs.ansible.com/)
- 🌐 Visit [TechConvergence.dev](https://techconvergence.dev) for more automation tools

## 🏆 Author

**Sunil Kumar**  
Website: [https://techconvergence.dev](https://techconvergence.dev)  
GitHub: [@techconvergenceDev](https://github.com/techconvergenceDev)

---

⭐ **If this project helped you, please give it a star!** ⭐# Ansible Semaphore Installer

Automated installation script for Ansible and Semaphore on Debian/Ubuntu systems.

**Made by Sunil Kumar** | [TechConvergence.dev](https://techconvergence.dev)

## Features

- **Complete Automation**: One-command installation of both Ansible and Semaphore
- **Latest Versions**: Automatically downloads the latest Semaphore release
- **Database Setup**: Configures MariaDB with secure random passwords
- **System Service**: Sets up systemd service for automatic startup
- **Security**: Creates dedicated user accounts and proper permissions

## Requirements

- Debian/Ubuntu system
- Root access
- Internet connection

## Quick Start

```bash
wget https://raw.githubusercontent.com/YOUR_USERNAME/ansible-semaphore-installer/main/install.sh
chmod +x install.sh
bash install.sh
```

Or one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ansible-semaphore-installer/main/install.sh | bash
```

## What Gets Installed

### Ansible
- Latest version from official PPA
- All required dependencies

### Semaphore
- Latest release from GitHub
- MariaDB database backend
- Systemd service configuration
- Web interface on port 3000

### Database
- MariaDB server
- Dedicated `semaphore_db` database
- Secure user with random password

## Post-Installation

### Access Semaphore
Visit `http://your-server-ip:3000` to access the web interface.

### Service Management
```bash
systemctl start semaphore.service
systemctl stop semaphore.service
systemctl restart semaphore.service
systemctl status semaphore.service
```

### View Logs
```bash
journalctl -u semaphore.service -f
```

### Database Credentials
Saved to `/home/semaphore/db_credentials.txt`

## Security Recommendations

1. Run `mysql_secure_installation` after installation
2. Configure firewall to restrict port 3000 access
3. Set up SSL/TLS for production environments
4. Change default passwords after first login

## File Locations

- Configuration: `/etc/semaphore/config.json`
- Service file: `/etc/systemd/system/semaphore.service`
- Database credentials: `/home/semaphore/db_credentials.txt`
- Logs: `journalctl -u semaphore.service`

## Troubleshooting

### Service Won't Start
```bash
systemctl status semaphore.service
journalctl -u semaphore.service --no-pager
```

### Database Connection Issues
Check credentials in `/home/semaphore/db_credentials.txt` and verify MariaDB is running:
```bash
systemctl status mariadb
```

### Port 3000 Not Accessible
Check firewall settings:
```bash
ufw status
iptables -L
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Check the [Semaphore documentation](https://docs.semaphoreui.com/)
- Review the [Ansible documentation](https://docs.ansible.com/)
- Visit [TechConvergence.dev](https://techconvergence.dev) for more automation tools

## Author

**Sunil Kumar**  
Website: [https://techconvergence.dev](https://techconvergence.dev)
