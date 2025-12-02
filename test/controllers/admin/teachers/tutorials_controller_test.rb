require "test_helper"
require "mocha/minitest"

class Admin::Teachers::TutorialsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @teacher = teachers(:one)
    @tutorial = tutorials(:one)
    # Ensure tutorial belongs to teacher
    @tutorial.update(teacher_id: @teacher.id)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get teacher_tutorials_url(@teacher)
    assert_response :success
    assert_match @tutorial.name, response.body
  end

  test "should search tutorials" do
    get teacher_tutorials_url(@teacher, q: @tutorial.name)
    assert_response :success
    assert_match @tutorial.name, response.body
  end
end
