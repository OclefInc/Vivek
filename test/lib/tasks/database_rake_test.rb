require "test_helper"
require "rake"
require "mocha/minitest"

class DatabaseRakeTest < ActiveSupport::TestCase
  setup do
    @prod_task = Rake::Task["database:prod"]
    @local_task = Rake::Task["database:local"]
  end

  teardown do
    @prod_task.reenable if @prod_task
    @local_task.reenable if @local_task
  end

  test "database:prod task exists and has description" do
    assert @prod_task, "database:prod task should exist"
    assert_equal "backup & download prod database", @prod_task.comment
  end

  test "database:local task exists and has description" do
    assert @local_task, "database:local task should exist"
    assert_equal "restore_local", @local_task.comment
  end

  test "database:prod runs heroku commands" do
    # We use a sequence to ensure order, though not strictly necessary
    seq = sequence("prod_commands")

    Object.any_instance.expects(:system).with("rm -rf latest.dump").in_sequence(seq).returns(true)
    Object.any_instance.expects(:system).with("heroku pg:backups:capture").in_sequence(seq).returns(true)
    Object.any_instance.expects(:system).with("heroku pg:backups:download").in_sequence(seq).returns(true)

    Rake::Task["database:prod"].invoke
  end

  test "database:local runs rails db commands" do
    seq = sequence("local_commands")

    Object.any_instance.expects(:system).with("rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1").in_sequence(seq).returns(true)
    Object.any_instance.expects(:system).with("rails db:create").in_sequence(seq).returns(true)
    Object.any_instance.expects(:system).with(regexp_matches(/pg_restore/)).in_sequence(seq).returns(true)

    Rake::Task["database:local"].invoke
  end

  test "database:prod removes existing dump file first" do
    Object.any_instance.expects(:system).with("rm -rf latest.dump").returns(true)
    Object.any_instance.expects(:system).with("heroku pg:backups:capture").returns(true)
    Object.any_instance.expects(:system).with("heroku pg:backups:download").returns(true)

    Rake::Task["database:prod"].invoke
  end

  test "database:local drops database with environment check disabled" do
    Object.any_instance.expects(:system).with("rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1").returns(true)
    Object.any_instance.expects(:system).with("rails db:create").returns(true)
    Object.any_instance.expects(:system).with("pg_restore --verbose --clean --no-acl --no-owner -h localhost -d vivek_dev latest.dump").returns(true)

    Rake::Task["database:local"].invoke
  end

  test "database:local creates database after dropping" do
    Object.any_instance.expects(:system).with("rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1").returns(true)
    Object.any_instance.expects(:system).with("rails db:create").returns(true)
    Object.any_instance.expects(:system).with("pg_restore --verbose --clean --no-acl --no-owner -h localhost -d vivek_dev latest.dump").returns(true)

    Rake::Task["database:local"].invoke
  end

  test "database:local restores from latest.dump file" do
    Object.any_instance.expects(:system).with("rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1").returns(true)
    Object.any_instance.expects(:system).with("rails db:create").returns(true)
    Object.any_instance.expects(:system).with("pg_restore --verbose --clean --no-acl --no-owner -h localhost -d vivek_dev latest.dump").returns(true)

    Rake::Task["database:local"].invoke
  end
end
