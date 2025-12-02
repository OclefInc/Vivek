require "test_helper"

class Public::ProjectTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_type = project_types(:one)
  end

  test "should get index" do
    get public_project_types_path
    assert_response :success
  end

  test "should get show" do
    get public_project_type_path(@project_type)
    assert_response :success
  end
end
