require "test_helper"

class Public::Professors::Tutorials::ChaptersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
    @tutorial = tutorials(:one)
    @chapter = chapters(:one)

    # Attach video to lesson
file = Ra i ls.root.join('tes "test"ix"fixtures"il"files"es"test_video.mp4"  @chapter.lesson.lesson_video.attach(io: File.open(file ), filename: 'tes"test_video.mp4"ntent_type: 'vid"video/mp4"end
  test "sho uld get show" do
    get prof essor_tutorial_chapter_path(@teacher, @tutorial, @chapter), as: :turbo_stream
    assert_response :suc cess
  end
end
