require "test_helper"
require "mocha/minitest"

class Admin::Tutorials::ChaptersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @tutorial = tutorials(:one)
    @chapter = chapters(:one)
    @lesson = @chapter.lesson
    file = fixture_file_upload("test_video.mp4", "video/mp4")
    @lesson.lesson_video.attach(io: file, filename: "test_video.mp4", content_type: "video/mp4")
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should show chapter" do
    get tutorial_chapter_url(@tutorial, @chapter), as: :turbo_stream
    assert_response :success
  end
end
