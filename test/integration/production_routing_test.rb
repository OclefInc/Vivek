require "test_helper"

class ProductionRoutingTest < ActionDispatch::IntegrationTest
  test "redirects missing routes to root in production" do
    # Simulate production environment for the constraint
    Rails.env.stubs(:production?).returns(true)

    get "/non-existent-route-#{SecureRandom.hex}"
    assert_redirected_to root_path
  end

  test "raises routing error or returns 404 for missing routes in non-production" do
    # Ensure we are not in production
    Rails.env.stubs(:production?).returns(false)

    begin
      get "/non-existent-route-#{SecureRandom.hex}"
      assert_response :not_found
    rescue ActionController::RoutingError
      # This is also acceptable behavior for missing routes in tests
      pass
    end
  end
end
