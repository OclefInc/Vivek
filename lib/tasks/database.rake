namespace :database do
  def resolve_pg_restore
    candidates = Dir.glob("/opt/homebrew/opt/postgresql@*/bin/pg_restore")
      .sort_by { |path| path[/postgresql@(\d+)/, 1].to_i }
      .reverse

    candidates.find { |path| File.executable?(path) } || "pg_restore"
  end

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
    pg_restore = resolve_pg_restore
    system "#{pg_restore} --verbose --clean --if-exists --no-acl --no-owner -h localhost -d vivek_dev latest.dump"
  end
end
