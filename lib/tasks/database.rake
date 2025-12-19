namespace :database do
  desc "backup & download prod database"
  task :prod, [ :path ] => [ :environment ] do |t, args|
    system "rm -rf latest.dump"
    system "heroku pg:backups:capture"
    system "heroku pg:backups:download"
  end

  desc "restore_local"
  task :local, [ :path ] => [ :environment ] do |t, args|
    system "rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1"
    system "rails db:create"
    system "pg_restore --verbose --clean --no-acl --no-owner -h localhost -d vivek_dev latest.dump"
  end
end
