# The Vivek Project

[![CI](https://github.com/OclefInc/Vivek/actions/workflows/ci.yml/badge.svg)](https://github.com/OclefInc/Vivek/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/OclefInc/Vivek/branch/main/graph/badge.svg)](https://codecov.io/gh/OclefInc/Vivek)

A free, open-source platform for documenting piano pedagogy on video. Provided by the Oclef Foundation.

## Features
- Video documentation of piano lessons
- OAuth login (Google, Apple, Facebook, GitHub)
- Card-based UI for teachers, students, projects, and tutorials
- Responsive, modern design (Tailwind CSS)
- Admin dashboard

## Getting Started

### Prerequisites
- Ruby (>= 3.2)
- Rails (>= 8.0)
- PostgreSQL
- Node.js (for asset compilation)
- Yarn (for managing JS dependencies)
- ImageMagick (for ActiveStorage variants)

### 1. Clone the repository
```bash
git clone https://github.com/OclefInc/vivek.git
cd vivek
```

### 2. Install dependencies
```bash
bundle install
yarn install
```

### 3. Setup environment variables
Copy `.env.example` to `.env` and fill in your OAuth credentials:
```bash
cp .env.example .env
```
Edit `.env` and add your Google, Apple, Facebook, and GitHub OAuth keys.

### 4. Setup the database
```bash
rails db:create db:migrate db:seed
```

### 5. Start the server
```bash
bin/dev
```
Visit [http://localhost:3000](http://localhost:3000)

## OAuth Setup
See `.env.example` for instructions on getting credentials for Google, Apple, Facebook, and GitHub.

## Deploying to Heroku

### 1. Create a Heroku app
```bash
heroku create vivek-project
```

### 2. Add buildpacks
```bash
heroku buildpacks:add heroku/ruby
heroku buildpacks:add heroku/nodejs
```

### 3. Provision PostgreSQL
```bash
heroku addons:create heroku-postgresql:hobby-dev
```

### 4. Set environment variables
Add your OAuth credentials and any secrets to Heroku config:
```bash
heroku config:set GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... APPLE_CLIENT_ID=... APPLE_TEAM_ID=... APPLE_KEY_ID=... APPLE_PRIVATE_KEY=... FACEBOOK_APP_ID=... FACEBOOK_APP_SECRET=... GITHUB_CLIENT_ID=... GITHUB_CLIENT_SECRET=...
```

### 5. Run migrations
```bash
heroku run rails db:migrate
```

### 6. Deploy
```bash
git push heroku main
```

### 7. (Optional) Seed the database
```bash
heroku run rails db:seed
```

## Troubleshooting
- If you get a database error, make sure PostgreSQL is running locally or provisioned on Heroku.
- For OAuth issues, double-check callback URLs and credentials.
- For asset issues, run `rails assets:precompile`.

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
MIT

## Contact
Questions? Email info@oclef.com
