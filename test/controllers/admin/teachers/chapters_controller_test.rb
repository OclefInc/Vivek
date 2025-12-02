require "test_helper"
require "mocha/minitest"

class Admin::Teachers::ChaptersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @teacher = teachers(:one)
    @lesson = lessons(:one)
    @chapter = chapters(:one)
    # Ensure lesson belongs to teacher
    @lesson.update(teacher_id: @teacher.id)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get teacher_chapters_url(@teacher)
    assert_response :success
    assert_match @chapter.name, response.body
  end
end
