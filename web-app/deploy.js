import { execSync } from 'child_process';
import { existsSync } from 'fs';
import { join } from 'path';

const BRANCH = 'gh-pages';
const DIST_DIR = 'dist';

function exec(command, options = {}) {
  console.log(`> ${command}`);
  try {
    return execSync(command, { stdio: 'inherit', ...options });
  } catch (error) {
    console.error(`Failed to execute: ${command}`);
    process.exit(1);
  }
}

function deploy() {
  console.log('🚀 Starting deployment to GitHub Pages...\n');

  // Check if dist directory exists
  if (!existsSync(DIST_DIR)) {
    console.error('❌ dist directory not found. Run "npm run build" first.');
    process.exit(1);
  }

  console.log('📦 Preparing deployment...');

  // Save current branch
  const currentBranch = execSync('git rev-parse --abbrev-ref HEAD')
    .toString()
    .trim();

  console.log(`Current branch: ${currentBranch}`);

  // Check if there are uncommitted changes
  const status = execSync('git status --porcelain').toString();
  if (status) {
    console.log('\n⚠️  Warning: You have uncommitted changes.');
    console.log('Continuing with deployment...\n');
  }

  // Check if gh-pages branch exists
  let branchExists = false;
  try {
    execSync(`git rev-parse --verify ${BRANCH}`, { stdio: 'pipe' });
    branchExists = true;
  } catch (e) {
    console.log(`Creating new ${BRANCH} branch...`);
  }

  // Create or checkout gh-pages branch
  if (branchExists) {
    exec(`git checkout ${BRANCH}`);
  } else {
    exec(`git checkout --orphan ${BRANCH}`);
    exec('git rm -rf .');
  }

  // Copy dist contents to root
  console.log('\n📁 Copying build files...');
  exec(`cp -r ${DIST_DIR}/* .`);

  // Create .nojekyll file to bypass Jekyll processing
  exec('touch .nojekyll');

  // Add and commit
  console.log('\n💾 Committing changes...');
  exec('git add -A');

  try {
    exec(`git commit -m "Deploy to GitHub Pages - ${new Date().toISOString()}"`);
  } catch (e) {
    console.log('No changes to commit.');
  }

  // Push to remote
  console.log('\n🔄 Pushing to GitHub...');
  let pushAttempts = 0;
  const maxRetries = 4;
  const retryDelays = [2000, 4000, 8000, 16000];

  while (pushAttempts <= maxRetries) {
    try {
      exec(`git push -u origin ${BRANCH}`);
      break;
    } catch (error) {
      pushAttempts++;
      if (pushAttempts > maxRetries) {
        console.error('\n❌ Failed to push after multiple attempts');
        process.exit(1);
      }
      const delay = retryDelays[pushAttempts - 1];
      console.log(`\n⏳ Push failed, retrying in ${delay / 1000}s... (Attempt ${pushAttempts}/${maxRetries})`);
      execSync(`sleep ${delay / 1000}`, { stdio: 'inherit' });
    }
  }

  // Return to original branch
  console.log(`\n↩️  Returning to ${currentBranch} branch...`);
  exec(`git checkout ${currentBranch}`);

  console.log('\n✅ Deployment complete!');
  console.log('🌐 Your site will be available at: https://djock.github.io/timelime/');
  console.log('\n💡 Note: It may take a few minutes for GitHub Pages to update.');
}

deploy();
