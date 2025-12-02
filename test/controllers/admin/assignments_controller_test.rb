require "test_helper"

class Admin::AssignmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @assignment = assignments(:one)
  end

  test "should redirect non-employee" do
    sign_in @user
    # User one is not an employee by default (email doesn't end in oclef.com)

    # Accessing a route that uses the authorize_user before_action
    get assignments_path
    assert_redirected_to root_path
  end

  test "should allow employee" do
    sign_in @user
    # Mock is_employee? to return true
    User.any_instance.stubs(:is_employee?).returns(true)

    get admin_path
    assert_response :success
  end

  test "should get index" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    get assignments_url
    assert_response :success
  end

  test "should get new" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    get new_assignment_url
    assert_response :success
  end

  test "should create assignment" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    assert_difference("Assignment.count") do
      post assignments_url, params: { assignment: { project_name: "New Project", student_name: "New Student", teacher_name: "New Teacher", project_type_id: project_types(:one).id } }
    end

    assert_redirected_to assignment_url(Assignment.last)
  end

  test "should show assignment" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    get assignment_url(@assignment)
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    get edit_assignment_url(@assignment)
    assert_response :success
  end

  test "should update assignment" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    patch assignment_url(@assignment), params: { assignment: { project_name: "Updated Project" } }
    assert_redirected_to assignment_url(@assignment.reload)
    assert_equal "Updated Project", @assignment.project_name
  end

  test "should destroy assignment" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    assert_difference("Assignment.count", -1) do
      delete assignment_url(@assignment)
    end

    assert_redirected_to assignments_url
  end

  test "should search assignments" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    get assignments_url(query: @assignment.project_name)
    assert_response :success
    assert_select "h3", text: @assignment.project_name
  end

  test "should filter assignments by teacher" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    teacher = teachers(:one)
    @assignment.update(teacher: teacher)
    Lesson.create!(assignment: @assignment, teacher: teacher, name: "Test Lesson", sort: 1)

    get assignments_url(teacher_id: teacher.id)
    assert_response :success
    assert_select "h3", text: @assignment.project_name
  end

  test "should get edit with field" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    get edit_assignment_url(@assignment, field: "description")
    assert_response :success
  end

  test "should fail to create assignment" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    assert_no_difference("Assignment.count") do
      post assignments_url, params: { assignment: { project_name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to create assignment json" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    assert_no_difference("Assignment.count") do
      post assignments_url(format: :json), params: { assignment: { project_name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to update assignment" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    patch assignment_url(@assignment), params: { assignment: { project_name: "" } }
    assert_response :unprocessable_entity
  end

  test "should fail to update assignment json" do
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)

    patch assignment_url(@assignment, format: :json), params: { assignment: { project_name: "" } }
    assert_response :unprocessable_entity
  end
end
