require "test_helper"

class Public::Professors::Tutorials::ChaptersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
    @tutorial = tutorials(:one)
    @chapter = chapters(:one)

    # Attach video to lesson
    file = Rails.root.join('test', 'fixtures', 'files', 'test_video.mp4')
    @chapter.lesson.lesson_video.attach(io: File.open(file), filename: 'test_video.mp4', content_type: 'video/mp4')
  end

  test "should get show" do
    get professor_tutorial_chapter_path(@teacher, @tutorial, @chapter), as: :turbo_stream
    assert_response :success
  end
end
