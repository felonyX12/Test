import os
import tempfile
import shutil
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import yt_dlp
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import subprocess
import logging
from pathlib import Path
import time

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Spotify API configuration
SPOTIFY_CLIENT_ID = os.environ.get('SPOTIFY_CLIENT_ID', '')
SPOTIFY_CLIENT_SECRET = os.environ.get('SPOTIFY_CLIENT_SECRET', '')

if SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET:
    spotify = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials(
        client_id=SPOTIFY_CLIENT_ID,
        client_secret=SPOTIFY_CLIENT_SECRET
    ))
else:
    spotify = None
    logger.warning("Spotify credentials not found. Using mock data.")

# YouTube download configuration
YT_DLP_OPTIONS = {
    'format': 'bestaudio/best',
    'extractaudio': True,
    'audioformat': 'wav',
    'outtmpl': '%(title)s.%(ext)s',
    'restrictfilenames': True,
    'noplaylist': True,
    'nocheckcertificate': True,
    'ignoreerrors': False,
    'logtostderr': False,
    'quiet': True,
    'no_warnings': True,
}

@app.route('/search', methods=['GET'])
def search_songs():
    """Search for songs using Spotify API"""
    query = request.args.get('q', '')
    limit = int(request.args.get('limit', 20))
    
    if not query:
        return jsonify({'error': 'Query parameter required'}), 400
    
    try:
        if spotify:
            results = spotify.search(q=query, type='track', limit=limit)
            tracks = []
            
            for item in results['tracks']['items']:
                track = {
                    'id': item['id'],
                    'name': item['name'],
                    'artist': ', '.join([artist['name'] for artist in item['artists']]),
                    'album': item['album']['name'],
                    'image': item['album']['images'][0]['url'] if item['album']['images'] else '',
                    'duration_ms': item['duration_ms'],
                    'preview_url': item['preview_url']
                }
                tracks.append(track)
            
            return jsonify({'tracks': tracks})
        else:
            # Mock data for testing without Spotify API
            mock_tracks = [
                {
                    'id': f'mock_{i}',
                    'name': f'Song {i}',
                    'artist': f'Artist {i}',
                    'album': f'Album {i}',
                    'image': 'https://via.placeholder.com/300x300',
                    'duration_ms': 210000,
                    'preview_url': None
                }
                for i in range(1, min(limit + 1, 11))
            ]
            return jsonify({'tracks': mock_tracks})
            
    except Exception as e:
        logger.error(f"Search error: {str(e)}")
        return jsonify({'error': 'Search failed'}), 500

@app.route('/process', methods=['POST'])
def process_song():
    """Download song from YouTube and separate vocals"""
    data = request.get_json()
    
    if not data or 'title' not in data or 'artist' not in data:
        return jsonify({'error': 'Title and artist required'}), 400
    
    title = data['title']
    artist = data['artist']
    search_query = f"{artist} {title}"
    
    temp_dir = None
    try:
        # Create temporary directory
        temp_dir = tempfile.mkdtemp()
        logger.info(f"Created temp directory: {temp_dir}")
        
        # Download audio from YouTube
        audio_file = download_from_youtube(search_query, temp_dir)
        if not audio_file:
            return jsonify({'error': 'Failed to download audio'}), 500
        
        # Separate vocals using Spleeter
        vocal_file = separate_vocals(audio_file, temp_dir)
        if not vocal_file:
            return jsonify({'error': 'Failed to separate vocals'}), 500
        
        # Return the processed audio file
        return send_file(
            vocal_file,
            as_attachment=True,
            download_name=f"{artist}_{title}_vocals.wav",
            mimetype='audio/wav'
        )
        
    except Exception as e:
        logger.error(f"Processing error: {str(e)}")
        return jsonify({'error': 'Processing failed'}), 500
    finally:
        # Cleanup temporary files
        if temp_dir and os.path.exists(temp_dir):
            try:
                shutil.rmtree(temp_dir)
                logger.info(f"Cleaned up temp directory: {temp_dir}")
            except Exception as e:
                logger.error(f"Cleanup error: {str(e)}")

def download_from_youtube(query, output_dir):
    """Download audio from YouTube using yt-dlp"""
    try:
        ydl_opts = YT_DLP_OPTIONS.copy()
        ydl_opts['outtmpl'] = os.path.join(output_dir, '%(title)s.%(ext)s')
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # Search for the video
            search_results = ydl.extract_info(f"ytsearch1:{query}", download=False)
            if not search_results or 'entries' not in search_results or not search_results['entries']:
                logger.error("No search results found")
                return None
            
            video_info = search_results['entries'][0]
            video_url = video_info['webpage_url']
            
            # Download the audio
            ydl.download([video_url])
            
            # Find the downloaded file
            for file in os.listdir(output_dir):
                if file.endswith(('.wav', '.mp3', '.m4a', '.webm')):
                    downloaded_file = os.path.join(output_dir, file)
                    
                    # Convert to wav if not already
                    if not file.endswith('.wav'):
                        wav_file = os.path.join(output_dir, 'audio.wav')
                        convert_to_wav(downloaded_file, wav_file)
                        return wav_file
                    else:
                        return downloaded_file
        
        return None
        
    except Exception as e:
        logger.error(f"YouTube download error: {str(e)}")
        return None

def convert_to_wav(input_file, output_file):
    """Convert audio file to WAV format using ffmpeg"""
    try:
        cmd = ['ffmpeg', '-i', input_file, '-acodec', 'pcm_s16le', '-ar', '44100', '-y', output_file]
        subprocess.run(cmd, check=True, capture_output=True)
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"FFmpeg conversion error: {str(e)}")
        return False

def separate_vocals(audio_file, output_dir):
    """Separate vocals using Spleeter"""
    try:
        # Create output subdirectory for Spleeter
        spleeter_output = os.path.join(output_dir, 'spleeter_output')
        os.makedirs(spleeter_output, exist_ok=True)
        
        # Run Spleeter command
        cmd = [
            'spleeter', 'separate',
            '-p', 'spleeter:2stems-16kHz',
            '-o', spleeter_output,
            audio_file
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            logger.error(f"Spleeter error: {result.stderr}")
            return None
        
        # Find the vocals file
        audio_name = Path(audio_file).stem
        vocals_file = os.path.join(spleeter_output, audio_name, 'vocals.wav')
        
        if os.path.exists(vocals_file):
            return vocals_file
        else:
            logger.error("Vocals file not found after separation")
            return None
            
    except Exception as e:
        logger.error(f"Vocal separation error: {str(e)}")
        return None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'spotify_available': spotify is not None})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)