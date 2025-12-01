require "test_helper"

class Public::StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:one)
  end

  test "should get index" do
    get public_students_path
    assert_response :success
  end

  test "should get show" do
    get public_student_path(@student)
    assert_response :success
  end
end
