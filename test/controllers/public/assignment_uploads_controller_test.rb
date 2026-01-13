require "test_helper"

class Public::AssignmentUploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assignment = assignments(:one)
  end

  test "should get new with valid token" do
    get new_assignment_upload_url(token: @assignment.signed_id)
    assert_response :success
  end

  test "should redirect to root with invalid token on new" do
    get new_assignment_upload_url(token: "invalid_token")
    assert_redirected_to root_path
    assert_equal "Invalid or expired upload link.", flash[:alert]
  end

  test "should create lesson with valid token and file" do
    file = fixture_file_upload("test_video.mp4", "video/mp4")
    assert_difference("Lesson.count") do
      post assignment_upload_url(token: @assignment.signed_id), params: {
        lesson: {
          lesson_video: file,
          name: "Test Lesson"
        }
      }
    end

    assert_redirected_to new_assignment_upload_path(@assignment.signed_id)
    assert_equal "Video uploaded successfully! You can upload another one.", flash[:notice]
  end

  test "should create lesson with default name when name is blank but video attached" do
    file = fixture_file_upload("test_video.mp4", "video/mp4")
    assert_difference("Lesson.count") do
      post assignment_upload_url(token: @assignment.signed_id), params: {
        lesson: {
          lesson_video: file,
          name: ""
        }
      }
    end

    lesson = Lesson.last
    assert_equal Date.today.to_s, lesson.name
    assert_redirected_to new_assignment_upload_path(@assignment.signed_id)
  end

  test "should redirect to root with invalid token on create" do
    post assignment_upload_url(token: "invalid_token"), params: {
      lesson: { name: "Test" }
    }
    assert_redirected_to root_path
    assert_equal "Invalid or expired upload link.", flash[:alert]
  end

  test "should fail to create lesson without name and video (validation error)" do
    # sending empty params triggers validation failure because name isn't set (no video attached, so default name logic skipped)
    assert_no_difference("Lesson.count") do
      post assignment_upload_url(token: @assignment.signed_id), params: {
        lesson: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h3", /Upload Video Lesson/
    assert_select "div.bg-red-50" # checks for error explanation container
  end
end
