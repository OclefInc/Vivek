require "test_helper"
require "mocha/minitest"

class Admin::ProfileControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @teacher = teachers(:teacher_with_user)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get show when user has teacher profile" do
    get profile_url
    assert_response :success
  end

  test "should redirect show when user has no teacher profile" do
    user_without_teacher = User.create!(email: "noteacher@example.com", password: "password123", name: "No Teacher")
    sign_in user_without_teacher

    get profile_url
    assert_redirected_to teachers_path
    assert_match(/don't have a teacher profile/, flash[:alert])
  end

  test "should get edit when user has teacher profile" do
    get edit_profile_url
    assert_response :success
  end

  test "should redirect edit when user has no teacher profile" do
    user_without_teacher = User.create!(email: "noteacher2@example.com", password: "password123", name: "No Teacher 2")
    sign_in user_without_teacher

    get edit_profile_url
    assert_redirected_to teachers_path
    assert_match(/don't have a teacher profile/, flash[:alert])
  end

  test "should update profile when user has teacher profile" do
    patch profile_url, params: { teacher: { name: "Updated Name" } }
    assert_redirected_to profile_url
    assert_equal "Updated Name", @teacher.reload.name
  end

  test "should redirect update when user has no teacher profile" do
    user_without_teacher = User.create!(email: "noteacher3@example.com", password: "password123", name: "No Teacher 3")
    sign_in user_without_teacher

    patch profile_url, params: { teacher: { name: "Updated Name" } }
    assert_redirected_to teachers_path
    assert_match(/don't have a teacher profile/, flash[:alert])
  end

  test "should fail to update profile with invalid data" do
    patch profile_url, params: { teacher: { name: "" } }
    assert_response :unprocessable_entity
  end
end
