require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "stores return_to location if present" do
    get root_path(return_to: "/some/path")
    assert_equal "/some/path", session["user_return_to"]
  end

  test "uses public layout for devise controllers" do
    get new_user_session_path
    assert_response :success
    # Public layout has this specific header class
    assert_select "header.bg-gradient-to-r"
    # Application layout has admin-layout class on body, public layout does not
    assert_select "body.admin-layout", false
  end
end

class ApplicationControllerUnitTest < ActiveSupport::TestCase
  test "handle_unknown_format redirects to root" do
    controller = ApplicationController.new
    controller.stubs(:root_path).returns("http://test.host/")
    controller.expects(:redirect_to).with("http://test.host/")
    controller.send(:handle_unknown_format)
  end
end
