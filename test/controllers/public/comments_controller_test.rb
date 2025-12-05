require "test_helper"

class Public::CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @comment = comments(:comment_for_tutorial)
    @user = users(:one)
    # Ensure the comment belongs to the user for update/destroy tests
    @comment.update(user: @user)
    @annotation = @comment.annotation
  end

  test "should get index" do
    sign_in @user
    get comments_path(annotation_type: @annotation.class.name, annotation_id: @annotation.id)
    assert_response :success
  end

  test "should create comment" do
    sign_in @user
    assert_difference("Comment.count") do
      post comments_path, params: { comment: { note: "New comment", annotation_id: @annotation.id, annotation_type: @annotation.class.name } }
    end

    assert_redirected_to comments_path(annotation_type: @annotation.class.name, annotation_id: @annotation.id)
  end

  test "should fail to create comment" do
    sign_in @user
    assert_no_difference("Comment.count") do
      post comments_path, params: { comment: { note: "", annotation_id: @annotation.id, annotation_type: @annotation.class.name } }
    end
    assert_response :unprocessable_entity
  end

  test "should update comment" do
    sign_in @user
    patch comment_path(@comment), params: { comment: { note: "Updated note", annotation_id: @annotation.id, annotation_type: @annotation.class.name } }
    assert_redirected_to comments_path(annotation_type: @annotation.class.name, annotation_id: @annotation.id)
  end

  test "should update comment with turbo stream" do
    sign_in @user
    patch comment_path(@comment), params: { comment: { note: "Updated note", annotation_id: @annotation.id, annotation_type: @annotation.class.name } }, as: :turbo_stream
    assert_response :success
  end

  test "should fail to update comment" do
    sign_in @user
    patch comment_path(@comment), params: { comment: { note: "", annotation_id: @annotation.id, annotation_type: @annotation.class.name } }
    assert_response :unprocessable_entity
  end

  test "should fail to update unauthorized comment" do
    sign_in users(:two)
    patch comment_path(@comment), params: { comment: { note: "Updated note", annotation_id: @annotation.id, annotation_type: @annotation.class.name } }
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "should get edit" do
    sign_in @user
    get edit_comment_path(@comment)
    assert_response :success
  end

  test "should fail to edit unauthorized comment" do
    sign_in users(:two)
    get edit_comment_path(@comment)
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "should destroy comment" do
    sign_in @user
    assert_difference("Comment.count", -1) do
      delete comment_path(@comment)
    end

    assert_redirected_to comments_path(annotation_type: @annotation.class.name, annotation_id: @annotation.id)
  end

  test "should fail to destroy unauthorized comment" do
    sign_in users(:two)
    assert_no_difference("Comment.count") do
      delete comment_path(@comment)
    end
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end
end
