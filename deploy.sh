#!/bin/bash

echo "🚀 Deploying Music App to Production..."

# Configuration
APP_DIR="/var/www/music-app"
DOMAIN="your-domain.com"  # Change this to your domain

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Use a user with sudo privileges."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install system dependencies
echo "🔧 Installing system dependencies..."
sudo apt install -y python3 python3-pip python3-venv ffmpeg nodejs npm nginx git

# Install PM2
if ! command_exists pm2; then
    echo "📦 Installing PM2..."
    sudo npm install -g pm2
fi

# Create application directory
echo "📁 Setting up application directory..."
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Copy application files (assuming current directory contains the app)
echo "📋 Copying application files..."
cp -r . $APP_DIR/
cd $APP_DIR

# Setup backend
echo "🐍 Setting up Python backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd ..

# Setup frontend
echo "⚛️  Setting up React frontend..."
cd frontend
npm install
npm run build
cd ..

# Create log directory
sudo mkdir -p /var/log/music-app
sudo chown $USER:$USER /var/log/music-app

# Setup Nginx
echo "🌐 Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/music-app

# Update domain in nginx config
sudo sed -i "s/your-domain.com/$DOMAIN/g" /etc/nginx/sites-available/music-app

# Enable site
sudo ln -sf /etc/nginx/sites-available/music-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
if sudo nginx -t; then
    echo "✅ Nginx configuration is valid"
    sudo systemctl restart nginx
    sudo systemctl enable nginx
else
    echo "❌ Nginx configuration error. Please check manually."
    exit 1
fi

# Setup environment variables
echo "🔐 Setting up environment variables..."
read -p "Enter your Spotify Client ID (or press Enter to skip): " SPOTIFY_ID
read -p "Enter your Spotify Client Secret (or press Enter to skip): " SPOTIFY_SECRET

# Update PM2 ecosystem file
if [ ! -z "$SPOTIFY_ID" ] && [ ! -z "$SPOTIFY_SECRET" ]; then
    sed -i "s/your_spotify_client_id/$SPOTIFY_ID/g" ecosystem.config.js
    sed -i "s/your_spotify_client_secret/$SPOTIFY_SECRET/g" ecosystem.config.js
fi

# Update paths in ecosystem config
sed -i "s|/var/www/music-app|$APP_DIR|g" ecosystem.config.js

# Start application with PM2
echo "🚀 Starting application..."
pm2 start ecosystem.config.js
pm2 save

# Setup PM2 to start on boot
pm2 startup systemd -u $USER --hp $HOME
echo "⚠️  Please run the command above that PM2 generated (if any) to enable auto-start on boot"

# Setup firewall (if ufw is available)
if command_exists ufw; then
    echo "🔒 Configuring firewall..."
    sudo ufw allow 22    # SSH
    sudo ufw allow 80    # HTTP
    sudo ufw allow 443   # HTTPS
    sudo ufw --force enable
fi

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Point your domain '$DOMAIN' to this server's IP address"
echo "2. Optional: Setup SSL certificate with Let's Encrypt:"
echo "   sudo apt install certbot python3-certbot-nginx"
echo "   sudo certbot --nginx -d $DOMAIN"
echo ""
echo "🌐 Your app should be accessible at:"
echo "   http://$DOMAIN (or http://your-server-ip)"
echo ""
echo "🔧 Management commands:"
echo "   pm2 status           # Check app status"
echo "   pm2 logs             # View logs"
echo "   pm2 restart all      # Restart app"
echo "   pm2 stop all         # Stop app"
echo "   sudo systemctl status nginx  # Check nginx status"