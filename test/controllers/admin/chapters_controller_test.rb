require "test_helper"
require "mocha/minitest"

class Admin::ChaptersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @lesson = lessons(:one)
    @chapter = chapters(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get new" do
    get new_lesson_chapter_url(@lesson)
    assert_response :success
  end

  test "should create chapter" do
    assert_difference("Chapter.count") do
      post lesson_chapters_url(@lesson), params: { chapter: { name: "New Chapter", start_time: 10 } }
    end
    assert_redirected_to lesson_url(@lesson)
  end

  test "should not create chapter with invalid params" do
    assert_no_difference("Chapter.count") do
      post lesson_chapters_url(@lesson), params: { chapter: { name: "", start_time: 10 } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_lesson_chapter_url(@lesson, @chapter)
    assert_response :success
  end

  test "should update chapter" do
    patch lesson_chapter_url(@lesson, @chapter), params: { chapter: { name: "Updated Chapter" } }
    assert_redirected_to lesson_url(@lesson)
    @chapter.reload
    assert_equal "Updated Chapter", @chapter.name
  end

  test "should not update chapter with invalid params" do
    patch lesson_chapter_url(@lesson, @chapter), params: { chapter: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy chapter" do
    assert_difference("Chapter.count", -1) do
      delete lesson_chapter_url(@lesson, @chapter)
    end
    assert_redirected_to lesson_url(@lesson)
  end
end
