# 🚀 Netlify + Railway Deployment Guide

Deploy your Music App with **Frontend on Netlify** (free) and **Backend on Railway** (free tier available).

## 📋 Prerequisites

1. **GitHub account** (to connect repositories)
2. **Netlify account** (sign up at [netlify.com](https://netlify.com))
3. **Railway account** (sign up at [railway.app](https://railway.app))
4. **Spotify Developer account** (optional - app works without it)

## 🔧 Step 1: Push Code to GitHub

```bash
# Initialize git repository (if not already done)
git init
git add .
git commit -m "Initial commit - Music App"

# Create GitHub repository and push
# Go to github.com, create new repository "music-app"
git remote add origin https://github.com/YOUR_USERNAME/music-app.git
git branch -M main
git push -u origin main
```

## 🐍 Step 2: Deploy Backend to Railway

1. **Sign up/Login** to [railway.app](https://railway.app)

2. **Create New Project:**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Connect your GitHub account
   - Choose your `music-app` repository

3. **Configure Backend:**
   - Railway will auto-detect the Python app
   - It will use the `railway.toml` configuration
   - Wait for deployment to complete (~3-5 minutes)

4. **Set Environment Variables:**
   - Go to your project dashboard
   - Click on "Variables" tab
   - Add these variables:
     ```
     FLASK_ENV=production
     SPOTIFY_CLIENT_ID=your_spotify_client_id (optional)
     SPOTIFY_CLIENT_SECRET=your_spotify_client_secret (optional)
     ```

5. **Get Backend URL:**
   - After deployment, Railway provides a URL like:
   - `https://music-app-backend-production.up.railway.app`
   - **Copy this URL** - you'll need it for frontend!

## ⚛️ Step 3: Deploy Frontend to Netlify

1. **Update Backend URL:**
   - Edit `frontend/.env.production`
   - Replace the URL with your Railway backend URL:
     ```
     REACT_APP_API_URL=https://YOUR_RAILWAY_URL_HERE
     ```
   - Commit and push this change:
     ```bash
     git add .
     git commit -m "Update backend URL for production"
     git push
     ```

2. **Sign up/Login** to [netlify.com](https://netlify.com)

3. **Deploy from GitHub:**
   - Click "New site from Git"
   - Choose "GitHub" and authorize
   - Select your `music-app` repository
   - Netlify will use the `netlify.toml` configuration:
     - Build command: `npm run build`
     - Publish directory: `frontend/build`
     - Base directory: `frontend/`

4. **Deploy:**
   - Click "Deploy site"
   - Wait for build to complete (~2-3 minutes)
   - Get your live URL: `https://YOUR_SITE_NAME.netlify.app`

## 🔗 Step 4: Connect Frontend to Backend

1. **Update CORS Settings:**
   - The backend is already configured to accept requests from Netlify domains
   - If you have a custom domain, update the CORS origins in `backend/app.py`

2. **Test the Connection:**
   - Visit your Netlify URL
   - Try searching for music
   - The app should connect to your Railway backend

## 🎯 Step 5: Custom Domain (Optional)

**For Netlify Frontend:**
1. Go to Site settings → Domain management
2. Add custom domain
3. Configure DNS records

**For Railway Backend:**
1. Go to project settings
2. Add custom domain
3. Update frontend environment variables

## 📊 Monitoring & Updates

**Check Status:**
- **Railway:** Dashboard shows logs and metrics
- **Netlify:** Deploy logs and site analytics

**Update App:**
```bash
# Make changes to your code
git add .
git commit -m "Update app"
git push

# Both Railway and Netlify will auto-deploy
```

**View Logs:**
- **Railway:** Click on your service → View logs
- **Netlify:** Site dashboard → Functions → View logs

## 💰 Pricing

**Railway (Backend):**
- Free tier: $5 credit per month
- Covers small to medium usage
- Upgrade if you need more resources

**Netlify (Frontend):**
- Free tier: 100GB bandwidth, 300 build minutes
- More than enough for personal use

## 🚨 Important Notes

### Backend Limitations
- **Cold starts:** Railway may have 1-2 second delays on first request
- **Resource limits:** Free tier has CPU/RAM limits
- **Build time:** Spleeter installation takes ~3-5 minutes on first deploy

### Frontend Optimizations
- Netlify provides global CDN
- Automatic HTTPS
- Instant deploys from GitHub

### Audio Processing
- Processing can take 1-3 minutes per song
- Large audio files may timeout on free tiers
- Consider upgrading for heavy usage

## 🔧 Troubleshooting

**Backend Issues:**
```bash
# Check Railway logs
railway logs

# Local testing
cd backend
source venv/bin/activate
python app.py
```

**Frontend Issues:**
```bash
# Test build locally
cd frontend
npm run build
npm start

# Check Netlify deploy logs in dashboard
```

**CORS Issues:**
- Ensure backend URL is correct in `.env.production`
- Check Railway backend logs for CORS errors
- Verify Netlify domain is allowed in backend CORS settings

## ✅ Success!

Your app should now be live at:
- **Frontend:** `https://YOUR_SITE_NAME.netlify.app`
- **Backend:** `https://YOUR_BACKEND.up.railway.app`

The app provides:
✅ Spotify-like music search  
✅ YouTube audio download  
✅ AI vocal separation  
✅ Real-time audio playback  
✅ Mobile-responsive design  
✅ Automatic HTTPS  
✅ Global CDN delivery