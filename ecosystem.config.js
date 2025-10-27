module.exports = {
  apps: [
    {
      name: 'music-app-backend',
      script: 'app.py',
      cwd: '/var/www/music-app/backend',
      interpreter: '/var/www/music-app/backend/venv/bin/python',
      env: {
        FLASK_ENV: 'production',
        SPOTIFY_CLIENT_ID: 'your_spotify_client_id',
        SPOTIFY_CLIENT_SECRET: 'your_spotify_client_secret'
      },
      instances: 1,
      exec_mode: 'fork',
      watch: false,
      max_memory_restart: '1G',
      error_file: '/var/log/music-app/backend-error.log',
      out_file: '/var/log/music-app/backend-out.log',
      log_file: '/var/log/music-app/backend-combined.log'
    }
  ]
};