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

  test "should get edit with field" do
    get edit_teacher_url(@teacher, field: "name")
    assert_response :success
  end

  test "should fail to create teacher" do
    assert_no_difference("Teacher.count") do
      post teachers_url, params: { teacher: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to create teacher json" do
    assert_no_difference("Teacher.count") do
      post teachers_url(format: :json), params: { teacher: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to update teacher" do
    patch teacher_url(@teacher), params: { teacher: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should fail to update teacher json" do
    patch teacher_url(@teacher, format: :json), params: { teacher: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should toggle visibility from public to private" do
    @teacher.update!(show_on_contributors: true)
    patch toggle_visibility_teacher_path(@teacher)
    assert_redirected_to teacher_url(@teacher)
    assert_equal false, @teacher.reload.show_on_contributors
  end

  test "should toggle visibility from private to public" do
    @teacher.update!(show_on_contributors: false)
    patch toggle_visibility_teacher_path(@teacher)
    assert_redirected_to teacher_url(@teacher)
    assert_equal true, @teacher.reload.show_on_contributors
  end

  test "should create teacher from user" do
    user_without_teacher = User.create!(email: "newteacher@example.com", password: "password123", name: "New Teacher")
    sign_in user_without_teacher

    assert_difference("Teacher.count") do
      post create_from_user_teachers_path
    end

    teacher = Teacher.last
    assert_equal user_without_teacher.id, teacher.user_id
    assert_equal "New Teacher", teacher.name
    assert_redirected_to teacher_url(teacher)
  end

  test "should not create duplicate teacher for user" do
    # The user fixture 'one' already has a teacher via teacher_with_user fixture
    user_with_teacher = users(:one)
    sign_in user_with_teacher

    assert_no_difference("Teacher.count") do
      post create_from_user_teachers_path
    end

    assert_redirected_to teacher_url(user_with_teacher.teacher)
    assert_match /already have a teacher profile/, flash[:notice]
  end

  test "should fail to create teacher from user when validation fails" do
    user_without_teacher = User.create!(email: "failteacher@example.com", password: "password123", name: "Fail Teacher")
    sign_in user_without_teacher

    # Stub the teacher association to return nil so it passes the first check
    user_without_teacher.stubs(:teacher).returns(nil)

    # Mock Teacher.new to return a teacher that will fail to save
    failing_teacher = Teacher.new(user_id: user_without_teacher.id, name: "")
    failing_teacher.valid? # Trigger validations
    Teacher.stubs(:new).returns(failing_teacher)

    post create_from_user_teachers_path

    assert_redirected_to teachers_path
    assert_match /Could not create teacher profile/, flash[:alert]
    assert_match /Name can't be blank/, flash[:alert]
  end
end
