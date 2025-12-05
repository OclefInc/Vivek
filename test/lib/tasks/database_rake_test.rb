require "test_helper"
require "rake"

class DatabaseRakeTest < ActiveSupport::TestCase
  setup do
    unless Rake::Task.task_defined?("database:prod")
      silence_warnings do
        Vivek::Application.load_tasks
      end
    end
    Rake::Task["database:prod"].reenable
    Rake::Task["database:local"].reenable
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
end
