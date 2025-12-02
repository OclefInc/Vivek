require "test_helper"
require "mocha/minitest"

class Admin::ProjectTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @project_type = project_types(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get project_types_url
    assert_response :success
  end

  test "should get new" do
    get new_project_type_url
    assert_response :success
  end

  test "should create project_type" do
    assert_difference("ProjectType.count") do
      post project_types_url, params: { project_type: { name: "New Type", description: "Desc" } }
    end
    assert_redirected_to project_types_url
  end

  test "should not create project_type with invalid params" do
    assert_no_difference("ProjectType.count") do
      post project_types_url, params: { project_type: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should show project_type" do
    get project_type_url(@project_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_type_url(@project_type)
    assert_response :success
  end

  test "should update project_type" do
    patch project_type_url(@project_type), params: { project_type: { name: "Updated Type" } }
    assert_redirected_to project_types_url
    @project_type.reload
    assert_equal "Updated Type", @project_type.name
  end

  test "should not update project_type with invalid params" do
    patch project_type_url(@project_type), params: { project_type: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy project_type" do
    project_type = ProjectType.create!(name: "To Destroy")
    assert_difference("ProjectType.count", -1) do
      delete project_type_url(project_type)
    end
    assert_redirected_to project_types_url
  end
end
