#!/bin/bash

echo "🚀 Preparing Music App for Netlify + Railway Deployment"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📋 Initializing Git repository..."
    git init
fi

# Add all files
echo "📦 Adding files to Git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    echo "💾 Committing changes..."
    git commit -m "Prepare for Netlify + Railway deployment"
fi

# Check if remote origin exists
if git remote get-url origin >/dev/null 2>&1; then
    echo "🔗 Remote origin already exists"
    echo "📤 Pushing to existing repository..."
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || git push -u origin main
else
    echo ""
    echo "📋 Next steps:"
    echo "1. Go to https://github.com and create a new repository called 'music-app'"
    echo "2. Copy the repository URL (e.g., https://github.com/USERNAME/music-app.git)"
    echo "3. Run these commands:"
    echo ""
    echo "   git remote add origin YOUR_GITHUB_REPO_URL"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
fi

echo ""
echo "🎯 Next: Follow the DEPLOYMENT_GUIDE.md for Netlify + Railway setup!"
echo ""
echo "Quick links:"
echo "🌐 Netlify: https://netlify.com"
echo "🚂 Railway: https://railway.app"
echo ""
echo "📖 Full guide: cat DEPLOYMENT_GUIDE.md"