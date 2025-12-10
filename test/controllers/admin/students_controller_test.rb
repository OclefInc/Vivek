require "test_helper"
require "mocha/minitest"

class Admin::StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @student = students(:one)
    file = fixture_file_upload("test_image.png", "image/png")
    @student.profile_picture.attach(io: file, filename: "test_image.png", content_type: "image/png")
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get students_url
    assert_response :success
  end

  test "should search students" do
    get students_url(query: @student.name)
    assert_response :success
    assert_match @student.name, response.body
  end

  test "should get new" do
    get new_student_url
    assert_response :success
  end

  test "should create student" do
    file = fixture_file_upload("test_image.png", "image/png")
    assert_difference("Student.count") do
      post students_url, params: { student: { name: "New Student", bio: "Bio", profile_picture: file } }
    end
    assert_redirected_to student_url(Student.last)
  end

  test "should fail to create student" do
    assert_no_difference("Student.count") do
      post students_url, params: { student: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to create student json" do
    assert_no_difference("Student.count") do
      post students_url(format: :json), params: { student: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should show student" do
    get student_url(@student)
    assert_response :success
  end

  test "should get edit" do
    get edit_student_url(@student)
    assert_response :success
  end

  test "should get edit with field" do
    get edit_student_url(@student, field: "name")
    assert_response :success
  end

  test "should update student" do
    patch student_url(@student), params: { student: { name: "Updated Student" } }
    assert_redirected_to student_url(@student.reload)
    assert_equal "Updated Student", @student.name
  end

  test "should fail to update student" do
    patch student_url(@student), params: { student: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should fail to update student json" do
    patch student_url(@student, format: :json), params: { student: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy student" do
    assert_difference("Student.count", -1) do
      delete student_url(@student)
    end
    assert_redirected_to students_url
  end

  test "should toggle visibility from public to private" do
    @student.update!(show_on_contributors: true)
    patch toggle_visibility_student_path(@student)
    assert_redirected_to student_url(@student)
    assert_equal false, @student.reload.show_on_contributors
  end

  test "should toggle visibility from private to public" do
    @student.update!(show_on_contributors: false)
    patch toggle_visibility_student_path(@student)
    assert_redirected_to student_url(@student)
    assert_equal true, @student.reload.show_on_contributors
  end
end
