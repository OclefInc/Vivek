require "test_helper"

class Public::ProfessorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
  end

  test "should get index" do
    get professors_path
    assert_response :success
  end

  test "should get show" do
    get professor_path(@teacher)
    assert_response :success
  end
end
