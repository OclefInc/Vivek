require "test_helper"
require "mocha/minitest"

class Admin::SkillCategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @skill_category = skill_categories(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get skill_categories_url
    assert_response :success
  end

  test "should search skill_categories" do
    get skill_categories_url(query: @skill_category.name)
    assert_response :success
    assert_match @skill_category.name, response.body
  end

  test "should show skill_category" do
    get skill_category_url(@skill_category)
    assert_response :success
  end
end
