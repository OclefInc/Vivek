require "test_helper"
require "mocha/minitest"

class Admin::LessonsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @assignment = assignments(:one)
    @lesson = lessons(:one)
    file = fixture_file_upload("test_video.mp4", "video/mp4")
    @lesson.lesson_video.attach(io: file, filename: "test_video.mp4", content_type: "video/mp4")
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get assignment_lessons_url(@assignment)
    assert_response :success
  end

  test "should get new" do
    get new_assignment_lesson_url(@assignment)
    assert_response :success
  end

  test "should create lesson" do
    assert_difference("Lesson.count") do
      post assignment_lessons_url(@assignment), params: { lesson: { name: "New Lesson", date: Date.today, assignment_id: @assignment.id } }
    end
    assert_redirected_to assignment_url(@assignment)
  end

  test "should fail to create lesson" do
    assert_no_difference("Lesson.count") do
      post assignment_lessons_url(@assignment), params: { lesson: { name: "", assignment_id: @assignment.id } }
    end
    assert_response :unprocessable_entity
  end

  test "should create lesson with return_url" do
    assert_difference("Lesson.count") do
      post assignment_lessons_url(@assignment, return_url: root_path), params: { lesson: { name: "New Lesson", date: Date.today, assignment_id: @assignment.id } }
    end
    assert_redirected_to root_path
  end

  test "should create lesson json" do
    assert_difference("Lesson.count") do
      post assignment_lessons_url(@assignment, format: :json), params: { lesson: { name: "New Lesson", date: Date.today, assignment_id: @assignment.id } }
    end
    assert_response :created
  end

  test "should fail to create lesson json" do
    assert_no_difference("Lesson.count") do
      post assignment_lessons_url(@assignment, format: :json), params: { lesson: { name: "", assignment_id: @assignment.id } }
    end
    assert_response :unprocessable_entity
  end

  test "should show lesson" do
    get lesson_url(@lesson)
    assert_response :success
  end

  test "should get edit" do
    get edit_lesson_url(@lesson)
    assert_response :success
  end

  test "should get edit with field" do
    get edit_lesson_url(@lesson, field: "name")
    assert_response :success
  end

  test "should update lesson" do
    patch lesson_url(@lesson), params: { lesson: { name: "Updated Lesson" } }
    @lesson.reload
    assert_redirected_to lesson_url(@lesson)
    assert_equal "Updated Lesson", @lesson.name
  end

  test "should fail to update lesson" do
    patch lesson_url(@lesson), params: { lesson: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should update lesson with teacher name" do
    patch lesson_url(@lesson), params: { lesson: { teacher_name: "New Teacher" } }
    @lesson.reload
    assert_equal "New Teacher", @lesson.teacher.name
  end

  test "should update lesson with return_url" do
    patch lesson_url(@lesson, return_url: root_path), params: { lesson: { name: "Updated Lesson" } }
    assert_redirected_to root_path
  end

  test "should update lesson json" do
    patch lesson_url(@lesson, format: :json), params: { lesson: { name: "Updated Lesson" } }
    assert_response :ok
  end

  test "should fail to update lesson json" do
    patch lesson_url(@lesson, format: :json), params: { lesson: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy lesson" do
    assert_difference("Lesson.count", -1) do
      delete lesson_url(@lesson)
    end
    assert_redirected_to lessons_url
  end
end
