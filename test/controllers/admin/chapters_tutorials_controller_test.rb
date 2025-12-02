require "test_helper"
require "mocha/minitest"

class Admin::ChaptersTutorialsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @chapters_tutorial = chapters_tutorials(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should destroy chapters_tutorial" do
    assert_difference("ChaptersTutorial.count", -1) do
      delete chapters_tutorial_url(@chapters_tutorial)
    end
    assert_redirected_to tutorial_url(@chapters_tutorial.tutorial)
  end
end
