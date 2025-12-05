require "test_helper"

class CommentMailerTest < ActionMailer::TestCase
  setup do
    @comment = comments(:one)
    @user = users(:one)
    @admin_email = "matthew@oclef.com"
  end

  test "notify_admin" do
    email = CommentMailer.notify_admin(@comment.id)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @admin_email ], email.to
    assert_equal [ "info@oclef.com" ], email.from
    assert_equal "New Comment", email.subject
    assert_match @comment.note.to_plain_text, email.body.encoded
  end

  test "notify_contributors" do
    # Ensure there are contributors other than the commenter
    contributor = users(:two)

    # Mock the contributors method on the annotation
    # We need to make sure the annotation returns a list of users including the contributor and the commenter
    # The mailer logic removes the commenter from the list

    # Since we can't easily mock the association chain in integration tests without mocha/stubs which might be tricky with fixtures
    # Let's try to set up the data correctly

    # Assuming annotation is a Lesson or Assignment which has contributors
    # Let's check what annotation is
    assert @comment.annotation

    # We need to stub the contributors method on the annotation instance
    # However, the mailer reloads the comment, so we need to stub on any instance of the annotation class
    # Or stub the method on the object that will be returned

    # Let's try to stub on the object that is already associated
    # And ensure the mailer uses this object or a similar one

    # A better approach might be to stub Comment.find to return our @comment object
    Comment.stubs(:find).with(@comment.id).returns(@comment)
    @comment.annotation.stubs(:contributors).returns([ contributor, @comment.user ])

    email = CommentMailer.notify_contributors(@comment.id)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ contributor.email ], email.to
    assert_equal [ "info@oclef.com" ], email.from
    assert_equal "New Comment", email.subject
    assert_match @comment.note.to_plain_text, email.body.encoded
  end

  test "notify_user when unpublished" do
    # We need to ensure Comment.find returns a comment that is NOT published
    # Since update might not be enough if there are callbacks or if the mailer loads a fresh copy
    # Let's stub find

    @comment.unpublished_date = Time.now
    Comment.stubs(:find).with(@comment.id).returns(@comment)

    email = CommentMailer.notify_user(@comment.id)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @comment.user.email ], email.to
    assert_equal [ "info@oclef.com" ], email.from
    assert_equal "Your comment has been unpublished", email.subject
  end

  test "notify_user when published does not send email" do
    @comment.update(unpublished_date: nil)
    email = CommentMailer.notify_user(@comment.id)

    assert_emails 0 do
      email.deliver_now
    end
  end
end
