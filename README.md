# 42 Inception

*This project has been created as part of the 42 curriculum by hermarti.*

## Description

This project aims to broaden knowledge of system administration by using Docker. It implements a small infrastructure composed of multiple Docker services orchestrated using Docker Compose. The infrastructure includes:

- **NGINX**: Reverse proxy with TLSv1.2/TLSv1.3 support
- **WordPress + PHP-FPM**: Content management system
- **MariaDB**: Relational database backend
- **Redis**: In-memory cache for WordPress
- **FTP**: File transfer protocol server
- **Adminer**: Database administration interface
- **Static Site**: Lightweight web server for static content
- **Portainer**: Docker container management interface

All services are containerized, isolated, and connected through a dedicated Docker network. Each container runs independently with proper volume persistence, secret management, and automatic restart on failure.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Root or sudo access (for volume management)
- A Linux virtual machine or compatible system

### Setup from Scratch

1. **Clone the repository** and navigate to the project directory:
   ```bash
   cd /path/to/42_Inception
   ```

2. **Create secret files** in the `secrets/` directory:
   ```bash
   mkdir -p secrets
   echo "inception_db" > secrets/db_name.txt
   echo "inception_user" > secrets/db_user.txt
   echo "secure_password_123" > secrets/db_password.txt
   echo "root_secure_password_456" > secrets/db_root_password.txt
   echo "owner_user" > secrets/wp_admin_user.txt
   echo "owner_password_789" > secrets/wp_admin_password.txt
   echo "wordpress_user" > secrets/wp_user.txt
   echo "wordpress_password_000" > secrets/wp_password.txt
   echo "ftp_user" > secrets/ftp_user.txt
   echo "ftp_password_111" > secrets/ftp_password.txt
   echo "portainer_user" > secrets/portainer_user.txt
   echo "portainer_password_222" > secrets/portainer_password.txt
   ```

3. **Configure your domain** in `/etc/hosts`:
   ```bash
   sudo sh -c 'echo "127.0.0.1 hermarti.42.fr" >> /etc/hosts'
   ```
   (Replace `hermarti` with your actual 42 login if different)

4. **Build and start the infrastructure**:
   ```bash
   make
   # Or explicitly:
   make up
   ```

5. **Access the services**:
   - WordPress: https://hermarti.42.fr
   - Adminer: https://hermarti.42.fr:8080
   - Portainer: https://hermarti.42.fr:9000
   - FTP: Connect to localhost on port 2121
   - Static Site: https://hermarti.42.fr:8081

### Common Commands

```bash
make up              # Start all containers
make down            # Stop all containers
make build           # Build Docker images
make clean           # Remove containers and volumes
make fclean          # Complete cleanup (removes images and volumes)
make re              # Rebuild from scratch
make logs            # View container logs in real-time
```

## Resources

### Docker & System Administration
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Understanding Volumes and Bind Mounts](https://docs.docker.com/storage/)
- [PID 1 and Daemons in Containers](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)

### NGINX & TLS
- [NGINX Configuration Guide](https://nginx.org/en/docs/)
- [HTTPS/TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [OpenSSL Certificate Generation](https://www.openssl.org/docs/)

### WordPress & PHP-FPM
- [WordPress Installation Guide](https://wordpress.org/documentation/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)
- [WP-CLI Documentation](https://developer.wordpress.org/cli/commands/)

### MariaDB
- [MariaDB Server Documentation](https://mariadb.com/kb/en/documentation/)
- [MySQL/MariaDB User Management](https://mariadb.com/kb/en/grant/)

### Redis & Caching
- [Redis Documentation](https://redis.io/documentation)
- [WordPress Redis Cache Plugin](https://wordpress.org/plugins/redis-cache/)

### Security & Secrets Management
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Environment Variables Best Practices](https://12factor.net/config)

### AI Usage in this Project

**Used for:**
- Debugging Docker networking and service communication issues
- Optimizing Dockerfile build processes and Alpine package selection
- Designing entrypoint scripts that follow Docker best practices
- Understanding PHP-FPM configuration and communication with NGINX
- Learning proper secrets management and secure credential handling

**Specific tasks:**
- Validating syntax of docker-compose configurations
- Troubleshooting MariaDB initialization and user setup
- Designing proper health checks and service dependencies
- Understanding WordPress core installation via WP-CLI

## Project Description

### Docker Architecture

This project uses Docker containers to create isolated, lightweight services that communicate through a dedicated network. Key design decisions:

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|------------------|--------|
| **Resource Usage** | Heavy - full OS per instance | Lightweight - shared kernel |
| **Startup Time** | Slow (minutes) | Fast (seconds) |
| **Isolation** | Full OS-level isolation | Process-level isolation |
| **Portability** | Tied to hypervisor | Runs anywhere Docker is installed |
| **Use Case** | Complex multi-OS infrastructure | Microservices, development, testing |

*Decision: Docker provides optimal resource efficiency and portability for this project's requirements.*

#### Secrets vs Environment Variables

| Aspect | Docker Secrets | Environment Variables |
|--------|----------------|----------------------|
| **Security** | Encrypted at rest, mounted in memory | Visible in process listing, logs |
| **Scope** | Per container, not exposed to logs | Container-wide, easily leaked |
| **Best For** | Passwords, API keys, certificates | Non-sensitive config (ports, domains) |
| **Manipulation** | Read-only file in `/run/secrets/` | Can be overridden easily |

*Decision: Secrets store all credentials (passwords, users). Environment variables store non-sensitive config (ports, domain names).*

**Current Implementation:**
- `.env` file: Domain name, ports, volume paths
- `secrets/` directory: All credentials (db passwords, admin users, FTP credentials)

#### Docker Network vs Host Network

| Aspect | Docker Network (Bridge) | Host Network |
|--------|------------------------|--------------|
| **Isolation** | Services isolated, internal communication | Direct access to host network |
| **Port Mapping** | Explicit ports configured | Direct port binding |
| **Security** | Protected internal communication | Exposed to host network |
| **Use Case** | Multi-service applications | Single-service deployments |

*Decision: Bridge network provides security and isolation between services while allowing controlled external access through NGINX.*

**Current Implementation:**
- `inception_network` (bridge driver)
- Internal service-to-service communication on private IPs
- External access only through NGINX on port 443

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|------------|
| **Management** | Docker-managed | Host filesystem-managed |
| **Performance** | Optimized for Docker | Can be slower on some systems |
| **Portability** | Portable across systems | Tied to host directory structure |
| **Permissions** | Handled by Docker | Host filesystem permissions apply |
| **Use Case** | Production, stateful services | Development, host access needed |

*Decision: Docker volumes for database and persistent data to ensure optimal performance and portability. Mounted at `/home/hermarti/data/` on host for backup and inspection.*

**Current Volumes:**
- `VOLUME_MARIADB`: Database files (persists across container restarts)
- `VOLUME_WORDPRESS`: WordPress files and uploads (shared with PHP-FPM)
- `VOLUME_REDIS`: Redis persistence data
- `VOLUME_PORTAINER`: Portainer configuration and data

### Service Communication Flow

```
Internet (Port 443)
    ↓
NGINX (Reverse Proxy)
    ├─→ WordPress + PHP-FPM (Port 9000 internal)
    ├─→ Adminer (Port 8080 internal)
    ├─→ Static Site (Port 8081 internal)
    └─→ Portainer (Port 9000 internal)

WordPress dependencies:
    ├─→ MariaDB (Port 3306 internal)
    └─→ Redis (Port 6379 internal)

Additional Services:
    ├─→ FTP Server (Port 2121 external)
    └─→ Portainer (Port 9000 external mapped)
```

### Data Persistence

All stateful services use Docker volumes to persist data:
- MariaDB data is stored in `/home/hermarti/data/mariadb/`
- WordPress files in `/home/hermarti/data/wordpress/`
- Redis data in `/home/hermarti/data/redis/`
- Portainer config in `/home/hermarti/data/portainer/`

This ensures data survives container restarts and enables backups.

### Security Considerations

1. **Credentials Management**: Stored in Docker secrets, not in code or environment
2. **TLS/HTTPS**: All external communication encrypted via NGINX
3. **Network Isolation**: Services communicate internally, external access controlled
4. **Image Scanning**: All images built from Alpine base (minimal attack surface)
5. **Root Avoidance**: Services run as non-root where possible (e.g., MySQL runs as `mysql` user)
