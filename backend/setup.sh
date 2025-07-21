#!/bin/bash

echo "Setting up Music App Backend..."

# Update system packages
sudo apt-get update

# Install system dependencies
sudo apt-get install -y python3 python3-pip ffmpeg

# Install yt-dlp globally
sudo pip3 install yt-dlp

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

echo "Backend setup complete!"
echo ""
echo "To run the backend:"
echo "1. Set your Spotify API credentials:"
echo "   export SPOTIFY_CLIENT_ID='your_client_id'"
echo "   export SPOTIFY_CLIENT_SECRET='your_client_secret'"
echo "2. Activate virtual environment: source venv/bin/activate"
echo "3. Run the app: python app.py"
echo ""
echo "The backend will be available at http://localhost:5000"