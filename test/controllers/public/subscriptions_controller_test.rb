require "test_helper"

class Public::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @project = assignments(:one)
    @subscription = @project.subscriptions.create(user: @user)
  end

  test "should get index" do
    sign_in @user
    get subscriptions_path
    assert_response :success
  end

  test "should create subscription" do
    sign_in @user
    @subscription.destroy

    assert_difference("Subscription.count") do
      post project_subscription_path(@project)
    end

    assert_redirected_to project_path(@project)
  end

  test "should destroy subscription" do
    sign_in @user
    assert_difference("Subscription.count", -1) do
      delete project_subscription_path(@project)
    end

    assert_redirected_to project_path(@project)
  end
end
