require "test_helper"

class Public::Professors::TutorialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
    @tutorial = tutorials(:one)
  end

  # test "should get index" do
  #   get professor_tutorials_path(@teacher)
  #   assert_response :success
  # end

  test "should get show" do
    get professor_tutorial_path(@teacher, @tutorial)
    assert_response :success
  end
end
