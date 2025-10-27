# Private Music App with Vocal Separation

A full-stack web application that provides a Spotify-like interface for searching songs and automatically separating vocals from YouTube audio using AI-powered source separation.

## Features

- 🎵 Spotify-like UI for music discovery
- 🔍 Search songs using Spotify API metadata
- 📥 Automatic YouTube audio download via yt-dlp
- 🎤 AI-powered vocal separation using Spleeter
- 🎧 In-browser audio playback of isolated vocals
- 📱 Responsive design for desktop and mobile

## Tech Stack

**Backend:**
- Python Flask API
- Spotify Web API (spotipy)
- yt-dlp for YouTube downloads
- Spleeter for audio source separation
- FFmpeg for audio conversion

**Frontend:**
- React.js with modern hooks
- Axios for API requests
- Spotify-inspired dark theme CSS
- HTML5 Audio API

## Project Structure

```
music-app/
├── backend/
│   ├── app.py                 # Flask application
│   ├── requirements.txt       # Python dependencies
│   └── setup.sh              # Backend setup script
├── frontend/
│   ├── public/
│   │   └── index.html        # HTML template
│   ├── src/
│   │   ├── App.js            # Main React component
│   │   ├── App.css           # Spotify-like styling
│   │   ├── index.js          # React entry point
│   │   └── index.css         # Global styles
│   └── package.json          # Node.js dependencies
└── README.md                 # This file
```

## Setup Instructions

### Prerequisites

- Linux/macOS system (recommended)
- Python 3.8+ with pip
- Node.js 16+ with npm
- FFmpeg installed
- Spotify Developer Account (optional, works with mock data)

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Make setup script executable and run:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Set up Spotify API credentials (optional):**
   - Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Create a new app and get Client ID and Secret
   - Set environment variables:
   ```bash
   export SPOTIFY_CLIENT_ID='your_spotify_client_id'
   export SPOTIFY_CLIENT_SECRET='your_spotify_client_secret'
   ```

4. **Activate virtual environment and start backend:**
   ```bash
   source venv/bin/activate
   python app.py
   ```

Backend will be available at `http://localhost:5000`

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start development server:**
   ```bash
   npm start
   ```

Frontend will be available at `http://localhost:3000`

### Manual Installation (if setup.sh fails)

**System dependencies:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv ffmpeg

# macOS
brew install python ffmpeg
```

**Python dependencies:**
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Install yt-dlp:**
```bash
pip install yt-dlp
```

## Usage

1. **Start both servers** (backend on :5000, frontend on :3000)

2. **Search for music:**
   - Type song name, artist, or album in the search bar
   - Press Enter or click the search button

3. **Process and play vocals:**
   - Click the play button on any song card
   - Wait for processing (1-3 minutes depending on song length)
   - The isolated vocals will automatically play in the bottom player

4. **Audio controls:**
   - Use the HTML5 audio player for playback control
   - Vocals-only audio file is temporarily stored and cleaned up automatically

## API Endpoints

- `GET /search?q={query}&limit={number}` - Search tracks via Spotify API
- `POST /process` - Download from YouTube and separate vocals
- `GET /health` - Backend health check

## Important Notes

### Legal Compliance
- This application is intended for **personal use only**
- Ensure you comply with YouTube's Terms of Service
- Respect copyright laws and fair use guidelines
- Do not distribute downloaded content

### Performance
- Audio processing takes 1-3 minutes per song
- Longer songs require more processing time
- Ensure stable internet connection for YouTube downloads
- Audio files are automatically cleaned up after processing

### Limitations
- Vocal separation quality depends on the original recording
- Some songs may not separate perfectly
- Requires significant computational resources
- Internet connection required for both Spotify metadata and YouTube downloads

## Troubleshooting

**Backend Issues:**
- Ensure FFmpeg is installed and accessible
- Check Python virtual environment is activated
- Verify all dependencies installed correctly
- Check logs for specific error messages

**Frontend Issues:**
- Ensure backend is running on port 5000
- Clear browser cache if experiencing issues
- Check browser console for JavaScript errors

**Audio Processing Issues:**
- Ensure sufficient disk space for temporary files
- Check internet connection for YouTube downloads
- Some videos may be geo-restricted or unavailable

**Spotify API Issues:**
- Verify credentials are set correctly
- App works with mock data if Spotify API unavailable
- Check Spotify Developer Dashboard for API limits

## Dependencies

**Backend Python packages:**
- Flask 2.3.3 - Web framework
- Flask-CORS 4.0.0 - Cross-origin requests
- yt-dlp 2023.10.13 - YouTube downloader
- spotipy 2.22.1 - Spotify API client
- spleeter 2.3.2 - Audio source separation
- tensorflow 2.10.1 - ML framework (Spleeter dependency)
- librosa 0.10.1 - Audio analysis
- requests 2.31.0 - HTTP client

**Frontend Node.js packages:**
- react 18.2.0 - UI framework
- react-dom 18.2.0 - React DOM renderer
- react-scripts 5.0.1 - Development tools
- axios 1.5.0 - HTTP client

## Deployment

### **Option 1: VPS/Cloud Server (Traditional)**

**Automatic deployment:**
```bash
# On your server
git clone <your-repo> && cd music-app
chmod +x deploy.sh
./deploy.sh
```

**Manual deployment:**
```bash
# 1. Install dependencies
sudo apt update && sudo apt install -y python3 python3-pip python3-venv ffmpeg nodejs npm nginx

# 2. Setup application
sudo mkdir -p /var/www/music-app
sudo chown $USER:$USER /var/www/music-app
cp -r . /var/www/music-app && cd /var/www/music-app

# 3. Backend setup
cd backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && cd ..

# 4. Frontend setup
cd frontend && npm install && npm run build && cd ..

# 5. Configure Nginx
sudo cp nginx.conf /etc/nginx/sites-available/music-app
sudo ln -s /etc/nginx/sites-available/music-app /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# 6. Start with PM2
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save && pm2 startup
```

### **Option 2: Docker (Recommended)**

**Prerequisites:**
- Docker and Docker Compose installed
- Domain pointing to your server (optional)

**Quick start:**
```bash
# 1. Clone and configure
git clone <your-repo> && cd music-app
cp .env.example .env
# Edit .env with your Spotify credentials

# 2. Start with Docker Compose
docker-compose up -d

# 3. Check status
docker-compose ps
docker-compose logs
```

**Access your app:**
- Frontend: http://localhost (or your domain)
- Backend API: http://localhost:5000

### **Option 3: Cloud Platforms**

**Heroku:**
```bash
# Install Heroku CLI, then:
heroku create your-app-name
heroku buildpacks:add heroku/python
heroku buildpacks:add heroku/nodejs
git push heroku main
```

**DigitalOcean App Platform:**
1. Connect your GitHub repository
2. Configure build settings:
   - Backend: Python/Flask app
   - Frontend: Static site (React)
3. Set environment variables in dashboard

**AWS/Google Cloud:**
- Use Docker containers with ECS/Cloud Run
- Or deploy to EC2/Compute Engine using the VPS method

### **SSL Certificate (Production)**

**With Let's Encrypt (free):**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

**Manual certificate:**
```bash
# Add to nginx.conf
ssl_certificate /path/to/certificate.crt;
ssl_certificate_key /path/to/private.key;
```

### **Monitoring & Maintenance**

**Check app status:**
```bash
# Traditional deployment
pm2 status
pm2 logs
sudo systemctl status nginx

# Docker deployment
docker-compose ps
docker-compose logs
```

**Update app:**
```bash
# Traditional
cd /var/www/music-app
git pull
cd frontend && npm run build && cd ..
pm2 restart all

# Docker
docker-compose pull
docker-compose up -d --build
```

### **Performance Optimization**

**Server requirements:**
- Minimum: 2GB RAM, 2 CPU cores, 20GB storage
- Recommended: 4GB RAM, 4 CPU cores, 50GB storage
- Network: Good bandwidth for YouTube downloads

**Optimization tips:**
1. Use SSD storage for faster audio processing
2. Configure swap space for memory-intensive tasks
3. Monitor disk usage (temp files are cleaned automatically)
4. Consider CDN for static assets in production
5. Use Redis for caching search results (optional)

## License

This project is for personal educational use only. Please respect all applicable copyright laws and terms of service.