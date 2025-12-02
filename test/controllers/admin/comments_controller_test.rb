require "test_helper"
require "mocha/minitest"

class Admin::CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @comment = comments(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get admin_comments_url
    assert_response :success
  end

  test "should redirect non-employee" do
    User.any_instance.stubs(:is_employee?).returns(false)
    get admin_comments_url
    assert_redirected_to root_path
  end

  test "should search comments" do
    get admin_comments_url(query: "User One")
    assert_response :success
  end

  test "should get show" do
    get admin_comment_url(@comment)
    assert_response :success
  end

  test "should redirect non-employee show" do
    User.any_instance.stubs(:is_employee?).returns(false)
    get admin_comment_url(@comment)
    assert_redirected_to root_path
  end

  test "should destroy comment" do
    delete admin_comment_url(@comment)
    assert_redirected_to admin_comment_url(@comment)
  end

  test "should destroy comment json" do
    delete admin_comment_url(@comment, format: :json)
    assert_response :no_content
  end
end
