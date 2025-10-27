import React, { useState, useRef } from 'react';
import axios from 'axios';
import './App.css';

const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? (process.env.REACT_APP_API_URL || 'https://music-app-backend.up.railway.app')
  : 'http://localhost:5000';

function App() {
  const [searchQuery, setSearchQuery] = useState('');
  const [tracks, setTracks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [processing, setProcessing] = useState(false);
  const [currentAudio, setCurrentAudio] = useState(null);
  const [nowPlaying, setNowPlaying] = useState(null);
  const [error, setError] = useState('');
  const audioRef = useRef(null);

  const searchTracks = async () => {
    if (!searchQuery.trim()) return;

    setLoading(true);
    setError('');
    
    try {
      const response = await axios.get(`${API_BASE_URL}/search`, {
        params: { q: searchQuery, limit: 20 }
      });
      setTracks(response.data.tracks);
    } catch (err) {
      setError('Failed to search tracks');
      console.error('Search error:', err);
    }
    
    setLoading(false);
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      searchTracks();
    }
  };

  const processTrack = async (track) => {
    setProcessing(true);
    setError('');
    
    try {
      const response = await axios.post(`${API_BASE_URL}/process`, {
        title: track.name,
        artist: track.artist
      }, {
        responseType: 'blob',
        timeout: 120000 // 2 minute timeout
      });

      // Create blob URL for audio playback
      const audioBlob = new Blob([response.data], { type: 'audio/wav' });
      const audioUrl = URL.createObjectURL(audioBlob);
      
      // Clean up previous audio URL
      if (currentAudio) {
        URL.revokeObjectURL(currentAudio);
      }
      
      setCurrentAudio(audioUrl);
      setNowPlaying(track);
      
      // Play the audio
      if (audioRef.current) {
        audioRef.current.src = audioUrl;
        audioRef.current.play();
      }
      
    } catch (err) {
      setError('Failed to process track. Please try again.');
      console.error('Processing error:', err);
    }
    
    setProcessing(false);
  };

  const formatDuration = (ms) => {
    const minutes = Math.floor(ms / 60000);
    const seconds = ((ms % 60000) / 1000).toFixed(0);
    return `${minutes}:${seconds.padStart(2, '0')}`;
  };

  return (
    <div className="app">
      <div className="sidebar">
        <div className="logo">
          <h1>🎵 Music App</h1>
          <p>Vocal Separation</p>
        </div>
        
        <div className="nav-menu">
          <div className="nav-item active">
            <span>🔍 Search</span>
          </div>
          <div className="nav-item">
            <span>🎧 Now Playing</span>
          </div>
        </div>
      </div>

      <div className="main-content">
        <div className="search-bar">
          <input
            type="text"
            placeholder="Search for songs, artists, or albums..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            onKeyPress={handleKeyPress}
            className="search-input"
          />
          <button 
            onClick={searchTracks} 
            disabled={loading}
            className="search-button"
          >
            {loading ? '⏳' : '🔍'}
          </button>
        </div>

        {error && (
          <div className="error-message">
            ⚠️ {error}
          </div>
        )}

        {processing && (
          <div className="processing-message">
            <div className="spinner"></div>
            <p>Processing audio... This may take a few minutes.</p>
          </div>
        )}

        <div className="tracks-grid">
          {tracks.map((track) => (
            <div key={track.id} className="track-card">
              <div className="track-image">
                <img 
                  src={track.image || 'https://via.placeholder.com/160x160?text=♪'} 
                  alt={track.name}
                  onError={(e) => {
                    e.target.src = 'https://via.placeholder.com/160x160?text=♪';
                  }}
                />
                <div className="play-overlay">
                  <button 
                    className="play-button"
                    onClick={() => processTrack(track)}
                    disabled={processing}
                  >
                    {processing ? '⏳' : '▶️'}
                  </button>
                </div>
              </div>
              
              <div className="track-info">
                <h3 className="track-name">{track.name}</h3>
                <p className="track-artist">{track.artist}</p>
                <p className="track-album">{track.album}</p>
                <p className="track-duration">
                  {formatDuration(track.duration_ms)}
                </p>
              </div>
            </div>
          ))}
        </div>

        {tracks.length === 0 && !loading && (
          <div className="empty-state">
            <h2>🎵 Welcome to Music App</h2>
            <p>Search for your favorite songs to get started</p>
            <p>Click on any song to download and separate vocals from YouTube</p>
          </div>
        )}
      </div>

      {nowPlaying && (
        <div className="now-playing-bar">
          <div className="now-playing-info">
            <img 
              src={nowPlaying.image || 'https://via.placeholder.com/56x56?text=♪'} 
              alt={nowPlaying.name}
              className="now-playing-image"
            />
            <div>
              <p className="now-playing-name">{nowPlaying.name}</p>
              <p className="now-playing-artist">{nowPlaying.artist}</p>
            </div>
          </div>
          
          <div className="audio-controls">
            <audio 
              ref={audioRef}
              controls
              className="audio-player"
              onEnded={() => setNowPlaying(null)}
            />
          </div>
        </div>
      )}
    </div>
  );
}

export default App;