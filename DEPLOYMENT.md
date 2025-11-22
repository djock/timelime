# Deployment Instructions

## Current Status
✅ Code is complete and ready
✅ Built successfully locally
⏳ **Waiting for deployment to GitHub Pages**

## To Deploy to https://djock.github.io/timelime/

### Step 1: Merge to Main Branch

You have two options:

#### Option A: Merge via GitHub (Recommended)
1. Go to https://github.com/djock/timelime
2. Click "Pull requests" → "New pull request"
3. Set base: `main`, compare: `claude/github-pages-deploy-017x5oi6ZBM32wv9rXVR9zpZ`
4. Click "Create pull request"
5. Review and click "Merge pull request"

#### Option B: Merge via Command Line
```bash
git checkout main
git merge claude/github-pages-deploy-017x5oi6ZBM32wv9rXVR9zpZ
git push origin main
```

### Step 2: Configure GitHub Pages
1. Go to https://github.com/djock/timelime/settings/pages
2. Under **Source**, select **GitHub Actions**
3. Save the changes

### Step 3: Wait for Deployment
- GitHub Actions will automatically run (~2 minutes)
- Go to https://github.com/djock/timelime/actions to watch progress
- Once complete (green checkmark), visit https://djock.github.io/timelime/

## Recent Bug Fixes
- ✅ Fixed Gantt view year navigation (left/right arrows now work)
- ✅ Calendar should now refresh after adding events

## Testing Locally

If you have Node.js installed:
```bash
npm install
npm run dev
```

Then open http://localhost:5173/timelime/

## How GitHub Pages Works

```
Your Code (Svelte) → GitHub Actions → Build (npm run build) → Static Files → GitHub Pages
```

GitHub Pages only serves static files. GitHub Actions handles the build process automatically when you push to main.
