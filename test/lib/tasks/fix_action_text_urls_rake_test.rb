require "test_helper"
require "rake"

class FixActionTextUrlsRakeTest < ActiveSupport::TestCase
  setup do
    Vivek::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["action_text:fix_urls"].reenable
  end

  test "fix_urls replaces production URLs with localhost" do
    # Create a student with bio containing the target URLs
    student = students(:one)
    student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    student.bio = "Check out https://www.thevivekproject.com/some/path and https://thevivekproject.com/other"
    student.save!

    # Verify original content
    assert_includes student.bio.to_s, "https://www.thevivekproject.com"

    # Capture stdout to avoid cluttering test output
    assert_output(/Updated 1 Action Text records/) do
      Rake::Task["action_text:fix_urls"].invoke
    end

    # Reload and verify
    student.reload
    assert_includes student.bio.to_s, "http://localhost:3000/some/path"
    assert_includes student.bio.to_s, "http://localhost:3000/other"
    assert_not_includes student.bio.to_s, "https://www.thevivekproject.com"
    assert_not_includes student.bio.to_s, "https://thevivekproject.com"
  end

  test "fix_urls does not update records without target URLs" do
    student = students(:one)
    student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    student.bio = "Check out http://localhost:3000/already/local"
    student.save!

    assert_output(/Updated 0 Action Text records/) do
      Rake::Task["action_text:fix_urls"].invoke
    end

    student.reload
    assert_includes student.bio.to_s, "http://localhost:3000/already/local"
    # Note: ActionText update might not touch the parent record timestamp directly unless configured,
    # but the task updates the RichText record directly via update_column.
    # We can check that the body hasn't changed.
  end
end
