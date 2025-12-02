require "test_helper"
require "mocha/minitest"

class Admin::TutorialsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @tutorial = tutorials(:one)
    @teacher = teachers(:one)
    @skill_category = skill_categories(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get tutorials_url
    assert_response :success
  end

  test "should get new" do
    get new_tutorial_url(teacher_id: @teacher.id)
    assert_response :success
  end

  test "should create tutorial" do
    assert_difference("Tutorial.count") do
      post tutorials_url, params: { tutorial: { name: "New Tutorial", description: "Desc", teacher_id: @teacher.id, skill_category_id: @skill_category.id } }
    end
    assert_redirected_to tutorial_url(Tutorial.last)
  end

  test "should show tutorial" do
    get tutorial_url(@tutorial)
    assert_response :success
  end

  test "should get edit" do
    get edit_tutorial_url(@tutorial)
    assert_response :success
  end

  test "should update tutorial" do
    patch tutorial_url(@tutorial), params: { tutorial: { name: "Updated Tutorial" } }
    assert_redirected_to tutorial_url(@tutorial.reload)
    assert_equal "Updated Tutorial", @tutorial.name
  end

  test "should destroy tutorial" do
    tutorial = Tutorial.create!(name: "To Destroy", teacher: @teacher, skill_category: @skill_category)
    assert_difference("Tutorial.count", -1) do
      delete tutorial_url(tutorial)
    end
    assert_redirected_to tutorials_url
  end
end
