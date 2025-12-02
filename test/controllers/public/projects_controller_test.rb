require "test_helper"

class Public::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = assignments(:one)
  end

  test "should get index" do
    get projects_path
    assert_response :success
  end

  test "should get show" do
    get project_path(@project)
    assert_response :success
  end
end
