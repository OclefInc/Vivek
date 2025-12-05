require "test_helper"

class ApplicationControllerCoverageTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  class TestController < ApplicationController
    before_action :authorize_user

    def index
      render plain: "OK"
    end
  end

  tests TestController

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get "index" => "application_controller_coverage_test/test#index"
      root to: "application_controller_coverage_test/test#index"
    end
  end

  test "authorize_user allows employee" do
    user = users(:one)
    user.stubs(:is_employee?).returns(true)
    @controller.stubs(:current_user).returns(user)

    get :index
    assert_response :success
  end

  test "authorize_user redirects non-employee" do
    user = users(:one)
    user.stubs(:is_employee?).returns(false)
    @controller.stubs(:current_user).returns(user)

    get :index
    assert_redirected_to root_path
  end

  test "layout_by_resource returns application for non-devise controller" do
    # Ensure devise_controller? returns false (default for our TestController)
    assert_equal "application", @controller.send(:layout_by_resource)
  end

  test "layout_by_resource returns public for devise controller" do
    @controller.stubs(:devise_controller?).returns(true)
    assert_equal "public", @controller.send(:layout_by_resource)
  end

  test "store_return_to_location stores location when return_to is present" do
    user = users(:one)
    user.stubs(:is_employee?).returns(true)
    @controller.stubs(:current_user).returns(user)

    get :index, params: { return_to: "/test/path" }
    assert_equal "/test/path", session["user_return_to"]
  end
end
