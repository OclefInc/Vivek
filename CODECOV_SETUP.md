# Setting Up Coverage Badge on GitHub

## Steps to Display 100% Coverage on GitHub

### 1. Sign up for Codecov
1. Go to https://codecov.io/
2. Sign in with your GitHub account
3. Click "Add new repository"
4. Select the `OclefInc/Vivek` repository

### 2. Get Your Codecov Token
1. Once the repository is added, go to Settings → General
2. Copy the **Upload Token** (starts with something like `abc123...`)

### 3. Add Token to GitHub Secrets
1. Go to your GitHub repository: https://github.com/OclefInc/Vivek
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `CODECOV_TOKEN`
5. Value: Paste the token you copied from Codecov
6. Click **Add secret**

### 4. Push Your Changes
```bash
git add .
git commit -m "Add Codecov integration for coverage reporting"
git push
```

### 5. Verify It Works
1. After pushing, check the **Actions** tab on GitHub
2. The CI workflow should run and upload coverage to Codecov
3. Once complete, visit https://codecov.io/gh/OclefInc/Vivek
4. You should see your 100% coverage displayed!

### 6. The Badge
The badge in README.md will automatically show your coverage percentage:
- ✅ Green badge = 100% coverage
- 🟡 Yellow badge = 90-99% coverage
- 🔴 Red badge = <90% coverage

## What Was Changed

1. **`.github/workflows/ci.yml`** - Added `COVERAGE: true` env var and Codecov upload step
2. **`.simplecov`** - Added JSON formatter for CI environments
3. **`Gemfile`** - Added `simplecov-json` gem
4. **`README.md`** - Added CI and Codecov badges at the top

## Troubleshooting

If the badge shows "unknown":
- Check that the Codecov upload step succeeded in GitHub Actions
- Verify the `CODECOV_TOKEN` secret is set correctly
- Make sure the token has permissions to upload coverage

If coverage is not 100%:
- Run `COVERAGE=true bin/rails test` locally
- Check `public/coverage/index.html` to see what lines are missing
