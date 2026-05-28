# User Documentation - 42 Inception

This guide is intended for end users and administrators who need to run, manage, and maintain the Inception infrastructure.

## Understanding the Services

The Inception infrastructure provides the following services:

### 1. WordPress Website
- **Purpose**: Main content management system and website
- **Access**: https://hermarti.42.fr
- **Features**: 
  - Admin panel for content management
  - User-friendly interface for publishing
  - Integrated with MariaDB for content storage
  - Redis caching for performance

### 2. Database (MariaDB)
- **Purpose**: Stores all WordPress content, users, and configuration
- **Access**: Internal only (not exposed to internet)
- **Role**: Backend storage for WordPress

### 3. Admin Panel (Adminer)
- **Purpose**: Web-based database management interface
- **Access**: https://hermarti.42.fr:8080
- **Architecture**: Lightweight nginx + PHP proxies to WordPress PHP-FPM container
- **Features**: 
  - Browse and modify database directly
  - Execute SQL queries
  - Manage database structure

### 4. File Transfer (FTP Server)
- **Purpose**: Upload and download files to/from the WordPress directory
- **Access**: Connect via FTP client to `localhost:2121`
- **Passive Mode**: Ports 21000-21010 (configurable in .env)
- **Use Cases**: Bulk file uploads, direct file management

### 5. Static Content Server
- **Purpose**: Serves static website/resume showcase
- **Access**: https://hermarti.42.fr:8081
- **Note**: Non-PHP content in a separate container

### 6. Docker Manager (Portainer)
- **Purpose**: Visual interface for managing Docker containers
- **Access**: https://hermarti.42.fr:9000
- **Features**: 
  - Container status and logs
  - Resource usage monitoring
  - Container restart/stop controls

### 7. Cache Layer (Redis)
- **Purpose**: Speeds up WordPress by caching database queries
- **Access**: Internal only (automatic)
- **Benefit**: Improved performance and reduced database load

## Starting and Stopping the Project

### First-Time Setup

Before running the project for the first time, you need to:

1. **Create secret files** (credentials):
   ```bash
   mkdir -p /home/hermarti/Projects/42_Inception/secrets
   
   # Database credentials
   echo "inception_db" > /home/hermarti/Projects/42_Inception/secrets/db_name.txt
   echo "inception_user" > /home/hermarti/Projects/42_Inception/secrets/db_user.txt
   echo "SecureDBPass123!" > /home/hermarti/Projects/42_Inception/secrets/db_password.txt
   echo "SecureRootPass456!" > /home/hermarti/Projects/42_Inception/secrets/db_root_password.txt
   
   # WordPress admin credentials
   echo "owner_user" > /home/hermarti/Projects/42_Inception/secrets/wp_admin_user.txt
   echo "OwnerPass789!" > /home/hermarti/Projects/42_Inception/secrets/wp_admin_password.txt
   
   # WordPress secondary user
   echo "blog_user" > /home/hermarti/Projects/42_Inception/secrets/wp_user.txt
   echo "UserPass000!" > /home/hermarti/Projects/42_Inception/secrets/wp_password.txt
   
   # FTP credentials
   echo "ftp_user" > /home/hermarti/Projects/42_Inception/secrets/ftp_user.txt
   echo "FTPPass111!" > /home/hermarti/Projects/42_Inception/secrets/ftp_password.txt
   
   # Portainer credentials
   echo "admin" > /home/hermarti/Projects/42_Inception/secrets/portainer_user.txt
   echo "PortainerPass222!" > /home/hermarti/Projects/42_Inception/secrets/portainer_password.txt
   ```

2. **Configure your domain**:
   ```bash
   sudo sh -c 'echo "127.0.0.1 hermarti.42.fr" >> /etc/hosts'
   ```
   (Replace `hermarti` with your login if different)

3. **Ensure Docker is running**:
   ```bash
   sudo systemctl start docker
   ```

### Starting the Infrastructure

To start all services, navigate to the project directory and run:

```bash
cd /home/hermarti/Projects/42_Inception
make
```

or explicitly:

```bash
make up
```

The first run will:
- Build Docker images for all services
- Create volumes for persistent data
- Initialize the database
- Install WordPress
- Configure all services
- Start all containers

**Typical startup time**: 2-5 minutes on first run

### Stopping the Infrastructure

To stop all running services:

```bash
make down
```

This stops all containers but preserves your data and configuration. You can restart with `make up` anytime.

### Checking Service Status

To view logs from all services in real-time:

```bash
make logs
```

To view logs from a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

### Restarting the Project

To completely rebuild from scratch (removes all containers and images):

```bash
make fclean
make up
```

**Warning**: `make fclean` removes containers and images but preserves volumes (your data).

To also remove all data:

```bash
make fclean
sudo rm -rf /home/hermarti/data/
make up
```

## Accessing WordPress

### Logging into WordPress Admin

1. Open your browser and navigate to: **https://hermarti.42.fr**
2. Click "Admin Login" or go to: **https://hermarti.42.fr/wp-admin/**
3. Enter your credentials:
   - **Username**: Found in `secrets/wp_admin_user.txt`
   - **Password**: Found in `secrets/wp_admin_password.txt`

### Common WordPress Tasks

#### Creating a New Post
1. Log in to the WordPress admin
2. Navigate to Posts → Add New
3. Write your content
4. Click "Publish"

#### Adding a New User
1. Log in to the WordPress admin
2. Navigate to Users → Add New
3. Fill in the user details
4. Set a password
5. Click "Create User"

#### Installing a Plugin
1. Log in to the WordPress admin
2. Navigate to Plugins → Add New
3. Search for the plugin
4. Click "Install Now" → "Activate"

#### Managing Pages
1. Log in to the WordPress admin
2. Navigate to Pages
3. Create, edit, or delete pages as needed

## Managing Credentials

### Where Credentials Are Stored

All credentials are stored as files in the `secrets/` directory:

```
secrets/
├── db_name.txt              # Database name
├── db_user.txt              # Database user
├── db_password.txt          # Database password
├── db_root_password.txt     # Database root password
├── wp_admin_user.txt        # WordPress admin username
├── wp_admin_password.txt    # WordPress admin password
├── wp_user.txt              # WordPress regular user
├── wp_password.txt          # WordPress regular user password
├── ftp_user.txt             # FTP username
├── ftp_password.txt         # FTP password
├── portainer_user.txt       # Portainer username
└── portainer_password.txt   # Portainer password
```

### Accessing Credentials

To view a credential:

```bash
cat secrets/wp_admin_user.txt
```

### Changing Credentials

For WordPress admin password:
1. Log in to WordPress admin
2. Navigate to Users → Your Profile
3. Scroll down and change password
4. Update the secret file:
   ```bash
   echo "new_password" > secrets/wp_admin_password.txt
   ```

For database password:
1. Update the secret file
2. Rebuild containers:
   ```bash
   make fclean
   make up
   ```

For FTP password:
1. Update `secrets/ftp_password.txt`
2. Restart the FTP container:
   ```bash
   docker compose -f srcs/docker-compose.yml restart ftp
   ```

**Security Note**: Never commit secret files to Git. They are listed in `.gitignore` to prevent accidental exposure.

## Checking Service Health

### Using Portainer (Visual Method)

1. Open https://hermarti.42.fr:9000
2. Log in with credentials from `secrets/portainer_user.txt`
3. View:
   - Container status (Running/Stopped)
   - Resource usage (CPU, Memory)
   - Service logs
   - Network connections

### Using Command Line

Check if all containers are running:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected output (all containers should show "Up"):
```
NAME        IMAGE               STATUS
nginx       nginx:inception     Up
mariadb     mariadb:inception   Up
wordpress   wordpress:inception Up
redis       redis:inception     Up
ftp         ftp:inception       Up
adminer     adminer:inception   Up
static      static:inception    Up
portainer   portainer:inception Up
```

### Checking Individual Services

**NGINX (Web Server)**:
```bash
docker compose -f srcs/docker-compose.yml logs nginx
```
Look for "daemon off" to confirm it's running.

**WordPress/PHP-FPM**:
```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```
Look for "ready to handle connections" message.

**MariaDB**:
```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```
Look for "ready for connections" message.

### Manually Accessing Services

**Check NGINX is responding**:
```bash
curl -k https://hermarti.42.fr
```

**Test WordPress connection**:
```bash
curl -k https://hermarti.42.fr/wp-admin/
```

**Test database connection**:
```bash
docker compose -f srcs/docker-compose.yml exec wordpress mysql -h mariadb -u inception_user -p -e "SELECT 1;"
```
(Enter the database password from `secrets/db_password.txt`)

## Troubleshooting

### Service Won't Start

**Problem**: A container exits immediately after starting

**Solution**:
1. Check the logs:
   ```bash
   docker compose -f srcs/docker-compose.yml logs service_name
   ```
2. Common causes:
   - Missing secret files
   - Port already in use
   - Insufficient disk space
   - Corrupted volume data

**Fix**:
```bash
make clean
make up
```

### Can't Connect to Website

**Problem**: Browser shows "connection refused" or "unable to connect"

**Solutions**:
1. Check domain configuration in `/etc/hosts`:
   ```bash
   cat /etc/hosts | grep hermarti.42.fr
   ```
   Should show: `127.0.0.1 hermarti.42.fr`

2. Check NGINX container is running:
   ```bash
   docker compose -f srcs/docker-compose.yml ps nginx
   ```

3. Test HTTPS certificate:
   ```bash
   curl -k https://hermarti.42.fr -v
   ```

### Database Connection Errors

**Problem**: WordPress shows database connection error

**Solutions**:
1. Check MariaDB is running:
   ```bash
   docker compose -f srcs/docker-compose.yml logs mariadb
   ```

2. Verify database credentials in secrets:
   ```bash
   cat secrets/db_name.txt
   cat secrets/db_user.txt
   cat secrets/db_password.txt
   ```

3. Check if data directory exists:
   ```bash
   ls -la /home/hermarti/data/mariadb/
   ```

4. Restart database:
   ```bash
   docker compose -f srcs/docker-compose.yml restart mariadb
   ```

### High Resource Usage

**Problem**: System running slowly or consuming lots of memory

**Solutions**:
1. Check container resource usage:
   ```bash
   docker stats
   ```

2. Check disk space:
   ```bash
   df -h
   ```

3. Clear old logs:
   ```bash
   docker system prune -a
   ```

4. Increase available memory or reduce background processes

### FTP Connection Issues

**Problem**: Can't connect via FTP client

**Solutions**:
1. Verify FTP service is running:
   ```bash
   docker compose -f srcs/docker-compose.yml ps ftp
   ```

2. Check FTP credentials:
   ```bash
   cat secrets/ftp_user.txt
   cat secrets/ftp_password.txt
   ```

3. Connection settings:
   - Host: `localhost`
   - Port: `2121`
   - Username: (from ftp_user.txt)
   - Password: (from ftp_password.txt)
   - Use passive mode
   - Use explicit TLS/SSL if available

### Adminer Login Issues

**Problem**: Can't log into Adminer database manager

**Solutions**:
1. Access Adminer at: https://hermarti.42.fr:8080
2. Use these credentials:
   - Server: `mariadb`
   - Username: (from `secrets/db_user.txt`)
   - Password: (from `secrets/db_password.txt`)
   - Database: (from `secrets/db_name.txt`)

## Backing Up Data

### Backing Up WordPress Files

```bash
tar -czf wordpress_backup_$(date +%Y%m%d).tar.gz /home/hermarti/data/wordpress/
```

### Backing Up Database

```bash
docker compose -f srcs/docker-compose.yml exec mariadb mysqldump \
  -u inception_user \
  -p inception_db > wordpress_db_backup_$(date +%Y%m%d).sql
```
(Enter the database password when prompted)

### Backing Up Everything

```bash
tar -czf inception_full_backup_$(date +%Y%m%d).tar.gz \
  /home/hermarti/data/ \
  /home/hermarti/Projects/42_Inception/secrets/
```

## Monitoring Resources

### Real-Time Resource Usage

```bash
docker stats
```

Shows CPU, memory, network, and disk usage for each container.

### Container Restart History

```bash
docker compose -f srcs/docker-compose.yml ps --no-trunc
```

### System Resource Limits

Check how much space is available:
```bash
df -h /home/hermarti/data/
```

## Maintenance

### Regular Tasks

- **Weekly**: Review WordPress updates in admin panel
- **Monthly**: Check disk space usage
- **Quarterly**: Test backup restoration process
- **As needed**: Update Docker and Docker Compose

### Updating the Infrastructure

To apply updates (after pulling new code):

```bash
make fclean
make up
```

### Cleaning Up Old Data

To remove old Docker images and unused volumes:

```bash
docker system prune -a --volumes
```

**Warning**: This removes ALL unused Docker data. Use with caution.

## Getting Help

If you encounter issues:

1. Check logs: `make logs`
2. Review this guide for troubleshooting section
3. Check Docker Compose status: `docker compose -f srcs/docker-compose.yml ps`
4. Review individual container logs
5. Consult Docker and service documentation
