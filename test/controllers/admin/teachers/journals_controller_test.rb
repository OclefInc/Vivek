require "test_helper"
require "mocha/minitest"

class Admin::Teachers::JournalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @teacher = teachers(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get teacher_journals_url(@teacher)
    assert_response :success
  end
end
