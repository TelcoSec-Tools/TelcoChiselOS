#!/bin/bash
set -eo pipefail

echo "Installing Nginx, PHP-FPM, and SQLite extensions..."

export DEBIAN_FRONTEND=noninteractive
apt-get install -y nginx php-fpm php-sqlite3 sqlite3 sudo unzip git

# Derive installed PHP version (e.g. "8.3") so the nginx config doesn't break
# when Ubuntu ships a newer default PHP. Falls back to "8.3" if detection fails.
PHP_VER=$(php --version 2>/dev/null | grep -oP '^\S+\s+\K\d+\.\d+' | head -1)
PHP_VER="${PHP_VER:-8.3}"
echo "  PHP version detected: ${PHP_VER}"

echo "Deploying Dashboard..."
mkdir -p /var/www/html
rm -f /var/www/html/index.html

# Clone the dashboard from GitHub (Update this URL when the repository is available online)
DASHBOARD_REPO="https://github.com/TelcoSec/TelcoChisel-Dashboard.git"

echo "Attempting to clone dashboard from $DASHBOARD_REPO..."
if git ls-remote "$DASHBOARD_REPO" >/dev/null 2>&1; then
    git clone "$DASHBOARD_REPO" /tmp/dashboard_repo
    cp -r /tmp/dashboard_repo/html/* /var/www/html/ || cp -r /tmp/dashboard_repo/* /var/www/html/
    rm -rf /tmp/dashboard_repo
    chown -R www-data:www-data /var/www/html
    echo "Dashboard successfully deployed from GitHub."
else
    echo "WARNING: Dashboard repository not reachable or not yet available at $DASHBOARD_REPO."
    echo "Skipping dashboard UI deployment. Nginx and PHP are installed and ready."
fi

# Configure Nginx for PHP — use unquoted heredoc so $PHP_VER expands.
# nginx's own $ variables (like $uri) are escaped with \$ below.
cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VER}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Ensure PHP-FPM is configured correctly
systemctl enable nginx || true
systemctl enable "php${PHP_VER}-fpm" || true

# Setup sudoers for www-data to execute systemctl and other commands as telcosec
echo "Configuring sudoers for www-data..."
cat > /etc/sudoers.d/dashboard-www-data << 'EOF'
www-data ALL=(telcosec) NOPASSWD: /bin/systemctl start *
www-data ALL=(telcosec) NOPASSWD: /bin/systemctl stop *
www-data ALL=(telcosec) NOPASSWD: /bin/systemctl restart *
www-data ALL=(telcosec) NOPASSWD: /usr/bin/pkill *
www-data ALL=(telcosec) NOPASSWD: /bin/mkdir *
www-data ALL=(telcosec) NOPASSWD: /bin/chown *
EOF
chmod 0440 /etc/sudoers.d/dashboard-www-data

# Create data directory for the dashboard
echo "Preparing GSM data directory..."
mkdir -p /opt/telcosec/gsm_data/scripts/management
mkdir -p /opt/telcosec/gsm_data/config/templates
mkdir -p /opt/telcosec/gsm_data/backups

# Setup SQLite DB permissions so www-data can interact, but owned by telcosec
chown -R telcosec:telcosec /opt/telcosec/gsm_data
chmod -R 775 /opt/telcosec/gsm_data

# Ensure www-data is in the telcosec group to write to the DB if necessary
usermod -aG telcosec www-data

echo "Dashboard installation complete."
