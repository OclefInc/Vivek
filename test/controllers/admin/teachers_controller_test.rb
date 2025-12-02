require "test_helper"
require "mocha/minitest"

class Admin::TeachersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @teacher = teachers(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get teachers_url
    assert_response :success
  end

  test "should search teachers" do
    get teachers_url(query: @teacher.name)
    assert_response :success
    assert_match @teacher.name, response.body
  end

  test "should get new" do
    get new_teacher_url
    assert_response :success
  end

  test "should create teacher" do
    assert_difference("Teacher.count") do
      post teachers_url, params: { teacher: { name: "New Teacher", bio: "Bio" } }
    end
    assert_redirected_to teacher_url(Teacher.last)
  end

  test "should show teacher" do
    get teacher_url(@teacher)
    assert_response :success
  end

  test "should get edit" do
    get edit_teacher_url(@teacher)
    assert_response :success
  end

  test "should update teacher" do
    patch teacher_url(@teacher), params: { teacher: { name: "Updated Teacher" } }
    assert_redirected_to teacher_url(@teacher.reload)
    assert_equal "Updated Teacher", @teacher.name
  end

  test "should destroy teacher" do
    teacher = Teacher.create!(name: "To Destroy")
    assert_difference("Teacher.count", -1) do
      delete teacher_url(teacher)
    end
    assert_redirected_to teachers_url
  end
end
