require "test_helper"
require "rake"
require "mocha/minitest"

class CheckNilErrorsTaskTest < ActiveSupport::TestCase
  setup do
    @task = Rake::Task["views:check_nil_errors"]

    # Create temporary test view files
    @test_views_dir = Rails.root.join("tmp/test_views")
    FileUtils.mkdir_p(@test_views_dir)
  end

  teardown do
    @task.reenable
    FileUtils.rm_rf(@test_views_dir) if @test_views_dir.exist?
  end

  test "task exists" do
    assert @task, "views:check_nil_errors task should exist"
  end

  test "task detects chained methods without safe navigation" do
    create_test_view("unsafe_chain.html.erb", "<%= user.profile.name %>")

    output = capture_io do
      # Temporarily change Dir.glob to include test views
      Dir.stubs(:glob).returns([@test_views_dir.join("unsafe_chain.html.erb").to_s])
      @task.invoke
    end

    assert_match(/potential nil error/i, output.first)
  end

  test "task detects direct teacher access without nil check" do
    create_test_view("unsafe_teacher.html.erb", "<%= lesson.teacher.name %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("unsafe_teacher.html.erb").to_s])
      @task.invoke
    end

    assert_match(/potential nil error/i, output.first)
  end

  test "task ignores safe navigation operator" do
    create_test_view("safe_navigation.html.erb", "<%= lesson.teacher&.name %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("safe_navigation.html.erb").to_s])
      @task.invoke
    end

    # Should not report this as an issue
    assert_match(/no obvious nil errors/i, output.first)
  end

  test "task ignores presence checks" do
    create_test_view("with_presence.html.erb", "<% if lesson.teacher.present? %><%= lesson.teacher.name %><% end %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("with_presence.html.erb").to_s])
      @task.invoke
    end

    assert_match(/no obvious nil errors/i, output.first)
  end

  test "task detects direct user access" do
    create_test_view("unsafe_user.html.erb", "<%= @object.user.email %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("unsafe_user.html.erb").to_s])
      @task.invoke
    end

    assert_match(/potential nil error/i, output.first)
  end

  test "task detects direct student access" do
    create_test_view("unsafe_student.html.erb", "<%= assignment.student.name %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("unsafe_student.html.erb").to_s])
      @task.invoke
    end

    assert_match(/potential nil error/i, output.first)
  end

  test "task ignores try method" do
    create_test_view("with_try.html.erb", "<%= lesson.teacher.try(:name) %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("with_try.html.erb").to_s])
      @task.invoke
    end

    assert_match(/no obvious nil errors/i, output.first)
  end

  test "task handles empty views directory" do
    output = capture_io do
      Dir.stubs(:glob).returns([])
      @task.invoke
    end

    assert_match(/no obvious nil errors/i, output.first)
  end

  test "task groups issues by file" do
    create_test_view("multiple_issues.html.erb", <<~ERB)
      <%= lesson.teacher.name %>
      <%= assignment.student.email %>
    ERB

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("multiple_issues.html.erb").to_s])
      @task.invoke
    end

    assert_match(/multiple_issues\.html\.erb/i, output.first)
  end

  test "task provides recommendations" do
    create_test_view("needs_fix.html.erb", "<%= lesson.teacher.name %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("needs_fix.html.erb").to_s])
      @task.invoke
    end

    assert_match(/recommendations/i, output.first)
    assert_match(/safe navigation/i, output.first)
  end

  test "task shows line numbers for issues" do
    create_test_view("with_line_numbers.html.erb", <<~ERB)
      <div>
        <%= lesson.teacher.name %>
      </div>
    ERB

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("with_line_numbers.html.erb").to_s])
      @task.invoke
    end

    assert_match(/Line \d+/i, output.first)
  end

  test "task detects optional association access" do
    create_test_view("association.html.erb", "<%= @episode.teacher.display_avatar %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("association.html.erb").to_s])
      @task.invoke
    end

    assert_match(/optional association/i, output.first)
  end

  test "task counts and reports total issues found" do
    create_test_view("issue1.html.erb", "<%= lesson.teacher.name %>")
    create_test_view("issue2.html.erb", "<%= assignment.student.email %>")

    output = capture_io do
      Dir.stubs(:glob).returns([
        @test_views_dir.join("issue1.html.erb").to_s,
        @test_views_dir.join("issue2.html.erb").to_s
      ])
      @task.invoke
    end

    assert_match(/found \d+ potential nil error/i, output.first)
  end

  test "task shows file path in output" do
    create_test_view("test_file.html.erb", "<%= lesson.teacher.name %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("test_file.html.erb").to_s])
      @task.invoke
    end

    assert_match(/test_file\.html\.erb/, output.first)
  end

  test "task prints no errors message when all views are safe" do
    create_test_view("all_safe.html.erb", "<h1>Hello World</h1><p><%= @name %></p>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("all_safe.html.erb").to_s])
      @task.invoke
    end

    assert_match(/✅ No obvious nil errors found!/, output.first)
  end

  test "task prints no errors when view has only simple expressions" do
    create_test_view("simple.html.erb", "<div><%= user&.name %></div>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("simple.html.erb").to_s])
      @task.invoke
    end

    assert_match(/✅ No obvious nil errors found!/, output.first)
  end

  test "task skips lines with unless nil check" do
    # This tests line 40 - the second part of the condition (unless nil check)
    create_test_view("unless_nil.html.erb", "<% if lesson.teacher.present? %><%= lesson.teacher.name %><% end %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("unless_nil.html.erb").to_s])
      @task.invoke
    end

    # Should not report as error because it has presence check
    assert_match(/no obvious nil errors/i, output.first)
  end

  test "task detects pattern match and adds to issues" do
    # This tests line 42 - adding issues to the array
    create_test_view("pattern_match.html.erb", "<%= @episode.composition.name %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("pattern_match.html.erb").to_s])
      @task.invoke
    end

    # Should detect optional association access and add to issues array
    assert_match(/optional association/i, output.first)
    assert_match(/composition/, output.first)
  end

  test "task reports issues with all required fields" do
    create_test_view("full_issue.html.erb", "<%= lesson.teacher.display_avatar %>")

    output = capture_io do
      Dir.stubs(:glob).returns([@test_views_dir.join("full_issue.html.erb").to_s])
      @task.invoke
    end

    # Should contain file name, line number, type, and content
    assert_match(/full_issue\.html\.erb/, output.first)
    assert_match(/Line \d+/, output.first)
    assert_match(/teacher/, output.first)
  end

  private

  def create_test_view(filename, content)
    File.write(@test_views_dir.join(filename), content)
  end

  def capture_io
    require "stringio"
    old_stdout = $stdout
    $stdout = StringIO.new

    yield

    output = $stdout.string
    $stdout = old_stdout

    [output]
  end
end
