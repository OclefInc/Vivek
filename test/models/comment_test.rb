# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  annotation_type  :string
#  unpublished_date :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin_id         :integer
#  annotation_id    :integer
#  user_id          :integer
#
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "published_status returns correct string" do
    comment = comments(:one)
    assert_equal "published", comment.published_status

    comment.unpublished_date = Time.now
    assert_equal "unpublished", comment.published_status
  end

  test "toggle_publish toggles published status" do
    comment = comments(:one)
    admin_id = 123

    # Initially published
    assert comment.is_published?

    # Toggle to unpublished
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      comment.toggle_publish(admin_id)
    end

    assert_not comment.is_published?
    assert_not_nil comment.unpublished_date
    assert_equal admin_id, comment.admin_id

    # Toggle back to published
    comment.toggle_publish(admin_id)
    assert comment.is_published?
    assert_nil comment.unpublished_date
    assert_equal admin_id, comment.admin_id
  end

  test "content_validity validates presence of note" do
    comment = Comment.new
    comment.validate
    assert_includes comment.errors[:note], "cannot be blank"

    comment.note = "Some content"
    # Mock AI validator to pass
    AiContentValidator.stubs(:validate).returns([ true, nil ])
    comment.validate
    assert_not_includes comment.errors[:note], "cannot be blank"
  end

  test "content_validity calls AI validator" do
    comment = comments(:one)
    comment.note = "New content"

    # Expect AI validator to be called
    AiContentValidator.expects(:validate).with("New content").returns([ true, nil ])

    comment.save
  end

  test "content_validity skips AI validation when publishing/unpublishing" do
    comment = comments(:one)

    # Should NOT call AI validator
    AiContentValidator.expects(:validate).never

    comment.toggle_publish(123)
  end

  test "content_validity adds error when AI validation fails" do
    comment = Comment.new(user: users(:one), annotation: assignments(:one))
    comment.note = "Bad content"

    AiContentValidator.stubs(:validate).returns([ false, "Content is inappropriate" ])

    assert_not comment.save
    assert_includes comment.errors[:base], "Content is inappropriate"
  end

  test "email_notification sends email after create" do
    comment = Comment.new(user: users(:one), annotation: assignments(:one))
    comment.note = "Valid content"
    AiContentValidator.stubs(:validate).returns([ true, nil ])

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      comment.save!
    end
  end

  test "touches annotation on save" do
    assignment = assignments(:one)
    original_updated_at = assignment.updated_at

    travel 1.second do
      comment = Comment.new(user: users(:one), annotation: assignment)
      comment.note = "Touching content"
      AiContentValidator.stubs(:validate).returns([ true, nil ])
      comment.save!

      assert_operator assignment.reload.updated_at, :>, original_updated_at
    end
  end

  test "destroys associated likes when destroyed" do
    comment = comments(:one)
    Like.create!(user: users(:one), likeable: comment)

    assert_difference "Like.count", -1 do
      comment.destroy
    end
  end

  test "validates presence of user" do
    comment = Comment.new(annotation: assignments(:one))
    comment.note = "Content"
    assert_not comment.valid?
    assert_includes comment.errors[:user], "must exist"
  end

  test "validates presence of annotation" do
    comment = Comment.new(user: users(:one))
    comment.note = "Content"
    assert_not comment.valid?
    assert_includes comment.errors[:annotation], "must exist"
  end
end
