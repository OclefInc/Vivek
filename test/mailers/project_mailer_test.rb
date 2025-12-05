require "test_helper"

class ProjectMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
    @lesson = lessons(:one)
    @project = @lesson.assignment
  end

  test "new_lesson_notification" do
    email = ProjectMailer.new_lesson_notification(@user, @lesson)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_equal [ "info@oclef.com" ], email.from
    assert_equal "New Lesson Added: #{@project.name}", email.subject
    assert_match @lesson.name, email.body.encoded
    assert_match @project.name, email.body.encoded
  end
end
