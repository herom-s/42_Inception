# Developer Documentation - 42 Inception

This guide is for developers who need to set up, build, modify, and maintain the Inception infrastructure from scratch.

## Environment Setup from Scratch

### Prerequisites

- Linux (Debian/Ubuntu-based or Alpine VM recommended)
- Docker and Docker Compose installed
- Git for version control
- Text editor or IDE (VS Code recommended)
- sudo access for Docker and volume management

### Installing Docker

**On Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

**On Alpine**:
```bash
apk add docker docker-compose
sudo rc-service docker start
sudo addgroup $USER docker
newgrp docker
```

### Cloning the Project

```bash
git clone <repository-url> /home/hermarti/Projects/42_Inception
cd /home/hermarti/Projects/42_Inception
```

### Creating Configuration Files

#### 1. Environment File (`.env`)

Located at `srcs/.env`, defines non-sensitive configuration:

```bash
# User login (replace with your 42 login)
USER_NAME=hermarti

# Port Configuration
WEB_PORT=443                    # NGINX HTTPS port
WP_PORT=9000                    # PHP-FPM internal port
DB_PORT=3306                    # MariaDB internal port
FTP_PORT=2121                   # FTP server port
FTP_PASV_MIN_PORT=21000         # FTP passive mode min port
FTP_PASV_MAX_PORT=21010         # FTP passive mode max port
REDIS_PORT=6379                 # Redis internal port
ADMINER_PORT=8080               # Adminer web port
STATIC_PORT=8081                # Static site port
PORTAINER_PORT=9000             # Portainer web port

# Service Configuration
DOMAIN_NAME=hermarti.42.fr      # Must match /etc/hosts entry
REDIS_HOST=redis                # Service name in docker-compose

# Volume Paths (where data persists on host)
VOLUME_MARIADB=/home/${USER_NAME}/data/mariadb
VOLUME_WORDPRESS=/home/${USER_NAME}/data/wordpress
VOLUME_REDIS=/home/${USER_NAME}/data/redis
VOLUME_PORTAINER=/home/${USER_NAME}/data/portainer

# Docker Compose File Location
DOCKER_COMPOSE_FILE=./srcs/docker-compose.yml
```

**Note**: All environment variables are exported by the Makefile, making them available to Docker Compose.

**Volumes**: Data is persisted using Docker-managed named volumes with local driver and bind mount options. This ensures:
- Volumes appear in `docker volume ls` (evaluation requirement)
- Data is stored in `/home/USER_NAME/data/` paths on host
- Proper Docker volume management and lifecycle

#### 2. Secret Files (`secrets/`)

Create secret files for all credentials:

```bash
mkdir -p secrets

# Database Credentials
echo "inception_db" > secrets/db_name.txt
echo "inception_user" > secrets/db_user.txt
echo "secure_db_password_123" > secrets/db_password.txt
echo "secure_root_password_456" > secrets/db_root_password.txt

# WordPress Credentials
echo "inception_owner" > secrets/wp_admin_user.txt
echo "secure_owner_password_789" > secrets/wp_admin_password.txt
echo "inception_user" > secrets/wp_user.txt
echo "secure_user_password_000" > secrets/wp_password.txt

# FTP Credentials
echo "inception_ftp" > secrets/ftp_user.txt
echo "secure_ftp_password_111" > secrets/ftp_password.txt

# Portainer Credentials
echo "admin" > secrets/portainer_user.txt
echo "secure_portainer_password_222" > secrets/portainer_password.txt
```

**Security**: These files are in `.gitignore` and should never be committed.

#### 3. Domain Configuration

Add domain mapping to your system's hosts file:

```bash
sudo sh -c 'echo "127.0.0.1 hermarti.42.fr" >> /etc/hosts'
```

Verify:
```bash
cat /etc/hosts | grep hermarti
```

### Directory Structure After Setup

```
42_Inception/
├── Makefile                          # Build automation
├── README.md                         # Main documentation
├── USER_DOC.md                       # User guide
├── DEV_DOC.md                        # This file
├── .gitignore                        # Git exclusions
├── .git/                             # Git repository
├── secrets/                          # Credential files (NOT in git)
│   ├── .gitkeep
│   ├── db_name.txt
│   ├── db_user.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_user.txt
│   ├── wp_admin_password.txt
│   ├── wp_user.txt
│   ├── wp_password.txt
│   ├── ftp_user.txt
│   ├── ftp_password.txt
│   ├── portainer_user.txt
│   └── portainer_password.txt
└── srcs/                             # Source files
    ├── .env                          # Environment configuration
    ├── docker-compose.yml            # Docker Compose definition
    └── requirements/                 # Service definitions
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   ├── nginx.conf
        │   │   └── openssl.conf
        │   └── tools/
        │       └── nginx-entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── wordpress.conf
        │   └── tools/
        │       └── wordpress-entrypoint.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── mariadb.conf
        │   └── tools/
        │       └── mariadb-entrypoint.sh
        ├── redis/
        ├── ftp/
        ├── adminer/
        ├── static/
        └── portainer/
```

## Building and Launching

### Complete Build Process

```bash
cd /home/hermarti/Projects/42_Inception

# Step 1: Create volumes
make volumes

# Step 2: Build Docker images
make build

# Step 3: Start containers
make up
```

Or in one command:
```bash
make up
```

**What happens during build**:
1. Volumes are created in `/home/hermarti/data/`
2. Each Dockerfile in `requirements/*/` is built
3. Images tagged with `:inception` suffix
4. Containers start and initialize:
   - MariaDB initializes database
   - WordPress downloads and configures itself
   - NGINX generates SSL certificates
   - All services connect via `inception_network`

### Individual Build Commands

```bash
# Build only specific service
docker compose -f srcs/docker-compose.yml build nginx

# Build without cache (forced rebuild)
docker compose -f srcs/docker-compose.yml build --no-cache

# View build logs
docker compose -f srcs/docker-compose.yml build --verbose
```

## Managing Containers and Volumes

### Container Operations

```bash
# View running containers
docker compose -f srcs/docker-compose.yml ps

# View all containers (including stopped)
docker compose -f srcs/docker-compose.yml ps -a

# View detailed container info
docker compose -f srcs/docker-compose.yml ps --no-trunc

# Restart a specific container
docker compose -f srcs/docker-compose.yml restart wordpress

# Stop all containers
docker compose -f srcs/docker-compose.yml stop

# Remove containers (but keep volumes)
docker compose -f srcs/docker-compose.yml down

# Remove containers and volumes
docker compose -f srcs/docker-compose.yml down -v
```

### Volume Management

```bash
# List volumes
docker volume ls | grep inception

# Inspect a volume
docker volume inspect inception_mariadb

# View volume location on host
ls -la /home/hermarti/data/

# Backup volume
tar -czf backup_wordpress.tar.gz /home/hermarti/data/wordpress/

# Clear a volume
sudo rm -rf /home/hermarti/data/mariadb/mysql/*
```

### Accessing Container Shells

```bash
# Access WordPress container shell
docker compose -f srcs/docker-compose.yml exec wordpress sh

# Access MariaDB container shell
docker compose -f srcs/docker-compose.yml exec mariadb sh

# Access NGINX container shell
docker compose -f srcs/docker-compose.yml exec nginx sh

# Execute command in container
docker compose -f srcs/docker-compose.yml exec wordpress wp user list --allow-root
```

## Project Data Storage

### Data Persistence Strategy

The project uses Docker volumes to persist data across container restarts:

```
Host Machine:
    /home/hermarti/data/
    ├── mariadb/              ← Database files
    │   ├── mysql/           ← System databases
    │   ├── inception_db/    ← WordPress database
    │   └── ...
    ├── wordpress/            ← WordPress files and uploads
    │   ├── wp-config.php
    │   ├── wp-content/
    │   ├── wp-admin/
    │   └── ...
    ├── redis/                ← Redis persistence
    │   ├── dump.rdb
    │   └── ...
    └── portainer/            ← Portainer configuration
        ├── docker_config.json
        └── ...
```

### Data Location Inside Containers

```
Containers:
    wordpress:/var/www/html            ← Mounted to host /home/hermarti/data/wordpress/
    mariadb:/var/lib/mysql             ← Mounted to host /home/hermarti/data/mariadb/
    redis:/data                        ← Mounted to host /home/hermarti/data/redis/
    portainer:/data                    ← Mounted to host /home/hermarti/data/portainer/
```

### Checking Data Persistence

```bash
# View current WordPress files
ls -la /home/hermarti/data/wordpress/

# Check database file sizes
du -sh /home/hermarti/data/mariadb/*

# Monitor volume usage
df -h /home/hermarti/data/

# Check total size
du -sh /home/hermarti/data/
```

## Key Architectural Decisions

### Docker-Managed Volumes

The project uses **Docker-managed named volumes** with the `local` driver instead of simple bind mounts:

```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VOLUME_WORDPRESS}
```

**Why**: 
- Volumes appear in `docker volume ls` (evaluation requirement)
- Data persists in `/home/USER_NAME/data/` paths on host
- Proper Docker lifecycle management
- Can be backed up/inspected with `docker volume` commands

**Verification**:
```bash
docker volume ls | grep inception
docker volume inspect inception_wordpress_data
```

### Adminer Architecture

**Adminer runs nginx only** — PHP execution is delegated to the **WordPress PHP-FPM container** via network proxy:

```nginx
location ~ \.php$ {
    fastcgi_pass wordpress:${WP_PORT};  # Network proxy to wordpress service
}
```

**Why**:
- Follows microservices principle (single responsibility)
- Avoids duplicate PHP-FPM instances
- Meets subject requirement: "one process per container"
- Lighter Adminer container

### SSL Certificate Generation at Runtime

**NGINX generates SSL certificates at container startup** using runtime environment variables:

1. `openssl.conf` is a **template** with `${DOMAIN_NAME}` placeholder
2. **Entrypoint script** substitutes variables at runtime
3. Certificate is generated if it doesn't exist (persisted in volume)

**Why**:
- Allows domain name to be configurable via `.env`
- Certificates automatically match your domain
- Build-time cert generation would be static/incorrect

**How to regenerate**:
```bash
docker volume rm inception_nginx_certs  # Then rebuild
```

### Port Configuration via .env

**All service ports** are configurable via `.env`:

```bash
WEB_PORT=443
WP_PORT=9000
DB_PORT=3306
FTP_PORT=2121
FTP_PASV_MIN_PORT=21000
FTP_PASV_MAX_PORT=21010
ADMINER_PORT=8080
STATIC_PORT=8081
PORTAINER_PORT=9000
```

Change ports and recreate containers:
```bash
# Edit srcs/.env
# Then:
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml up
```

## Logging and Debugging

### Real-Time Logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs -f

# Specific service
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Last 50 lines
docker compose -f srcs/docker-compose.yml logs --tail=50 nginx

# Logs with timestamps
docker compose -f srcs/docker-compose.yml logs -f -t mariadb
```

### Debugging Container Startup

```bash
# Build with verbose output
docker compose -f srcs/docker-compose.yml build --verbose wordpress

# Start with interactive terminal
docker compose -f srcs/docker-compose.yml run --rm wordpress sh

# View startup entrypoint script
docker exec wordpress cat /usr/local/bin/wordpress-entrypoint.sh

# Check environment variables in container
docker exec wordpress env | grep -E "DOMAIN|WP_"
```

### Checking Database

```bash
# Access MariaDB client
docker compose -f srcs/docker-compose.yml exec mariadb mariadb-shell

# Or with password
docker compose -f srcs/docker-compose.yml exec mariadb mysql \
  -u $(cat secrets/db_user.txt) \
  -p$(cat secrets/db_password.txt) \
  -e "SELECT * FROM mysql.user;"

# Check database contents
docker compose -f srcs/docker-compose.yml exec mariadb mysql \
  -u $(cat secrets/db_user.txt) \
  -p$(cat secrets/db_password.txt) \
  inception_db -e "SHOW TABLES;"
```

### Testing Network Connectivity

```bash
# Test from WordPress container to MariaDB
docker compose -f srcs/docker-compose.yml exec wordpress \
  nc -zv mariadb 3306

# Test DNS resolution
docker compose -f srcs/docker-compose.yml exec wordpress \
  nslookup mariadb

# Check network interfaces
docker compose -f srcs/docker-compose.yml exec nginx ifconfig
```

## Modifying and Extending

### Adding a New Service

1. **Create directory**:
   ```bash
   mkdir -p srcs/requirements/newservice/{conf,tools}
   ```

2. **Create Dockerfile**:
   ```dockerfile
   FROM alpine:3.22.4
   
   RUN apk update && apk add --no-cache <packages>
   
   COPY ./conf/ /etc/
   COPY ./tools/entrypoint.sh /usr/local/bin/
   RUN chmod +x /usr/local/bin/entrypoint.sh
   
   EXPOSE 8000
   
   ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
   CMD ["your", "command"]
   ```

3. **Update docker-compose.yml**:
   ```yaml
   newservice:
       build: requirements/newservice
       image: newservice:inception
       container_name: newservice
       expose:
           - "8000"
       env_file:
           - .env
       networks:
           - inception_network
   ```

4. **Rebuild**:
   ```bash
   docker compose -f srcs/docker-compose.yml build newservice
   ```

### Modifying Existing Service

1. **Edit Dockerfile** or configuration files
2. **Rebuild**:
   ```bash
   docker compose -f srcs/docker-compose.yml build --no-cache <service>
   ```
3. **Restart**:
   ```bash
   docker compose -f srcs/docker-compose.yml up <service>
   ```

### Checking Image Layers

```bash
# View image history
docker image history wordpress:inception

# Inspect image details
docker image inspect nginx:inception

# View image size
docker images | grep inception
```

## Testing

### Health Checks

```bash
# NGINX - check certificate
openssl s_client -connect localhost:443 -servername hermarti.42.fr

# WordPress - check installation
curl -k https://hermarti.42.fr/wp-admin/setup-config.php

# Database - check connection
docker compose -f srcs/docker-compose.yml exec wordpress \
  mysql -h mariadb -u inception_user -p -e "SELECT 1;"

# Redis - check connectivity
docker compose -f srcs/docker-compose.yml exec wordpress redis-cli -h redis ping
```

### Performance Testing

```bash
# Check resource usage
docker stats

# Stress test WordPress
ab -n 1000 -c 10 https://hermarti.42.fr/

# Monitor disk I/O
iostat -x 1
```

## Makefile Targets

| Target | Purpose |
|--------|---------|
| `make all` | Default target: runs `make up` |
| `make volumes` | Create volume directories |
| `make build` | Build Docker images |
| `make up` | Start all containers |
| `make down` | Stop all containers |
| `make clean` | Stop and remove containers + volumes |
| `make fclean` | Full cleanup (includes removing images) |
| `make re` | Rebuild from scratch (`fclean` + `up`) |
| `make logs` | View real-time logs from all services |

## Advanced Debugging

### Network Inspection

```bash
# List networks
docker network ls

# Inspect inception_network
docker network inspect inception_network

# Connect to network for debugging
docker run --rm --network=inception_network alpine ping mariadb
```

### Container Process Tree

```bash
# View processes inside container
docker compose -f srcs/docker-compose.yml top wordpress

# Check if process is running
docker compose -f srcs/docker-compose.yml exec nginx pgrep -f nginx
```

### Rebuilding Without Cache

When changes aren't taking effect:

```bash
# Force rebuild all
docker compose -f srcs/docker-compose.yml build --no-cache --pull

# Force remove old images
docker rmi $(docker images -q "inception")
```

## CI/CD Considerations

For automated testing, use:

```bash
# Verify Dockerfile syntax
hadolint srcs/requirements/*/Dockerfile

# Check docker-compose syntax
docker compose -f srcs/docker-compose.yml config

# Run security scan
trivy image nginx:inception
```

## Performance Optimization

### Reducing Build Time

- Use `.dockerignore` files (already configured)
- Layer caching: place stable commands first
- Multi-stage builds (if needed)

### Runtime Performance

- Redis caching enabled for WordPress
- Volume location on fastest disk
- Monitor resource allocation
- Use Alpine base image (small footprint)

## Troubleshooting Development Issues

### Container won't start

```bash
docker compose -f srcs/docker-compose.yml build --no-cache <service>
docker compose -f srcs/docker-compose.yml logs <service>
```

### Files not updating in volume

```bash
# Check volume mount
docker inspect <container_id> | grep -A 10 Mounts

# Verify on host
ls -la /home/hermarti/data/wordpress/
```

### Network connectivity issues

```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  nc -zv service_name port

docker network inspect inception_network
```

### Database won't initialize

```bash
# Check logs
docker compose -f srcs/docker-compose.yml logs mariadb

# Verify secrets exist
ls -la secrets/

# Check volume
sudo ls -la /home/hermarti/data/mariadb/
```

## Documentation for Code Review

When submitting code:

1. **Comment complex sections** (entrypoints, network config)
2. **Document environment variables** in `.env` comments
3. **Explain design decisions** in commit messages
4. **Keep Dockerfiles minimal** and readable
5. **Test on fresh VM** before submission
