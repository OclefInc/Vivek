require "test_helper"

class Public::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @project = assignments(:one)
    # Use the existing subscription from fixtures instead of creating a new one
    @subscription = subscriptions(:one)
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

  test "should fail to create duplicate subscription" do
    sign_in @user
    # Subscription already exists from setup

    assert_no_difference("Subscription.count") do
      post project_subscription_path(@project)
    end

    assert_redirected_to project_path(@project)
    assert_equal "Unable to subscribe.", flash[:alert]
  end

  test "should destroy subscription" do
    sign_in @user
    assert_difference("Subscription.count", -1) do
      delete project_subscription_path(@project)
    end

    assert_redirected_to project_path(@project)
  end

  test "should fail to destroy non-existent subscription" do
    sign_in @user
    @subscription.destroy

    assert_no_difference("Subscription.count") do
      delete project_subscription_path(@project)
    end

    assert_redirected_to project_path(@project)
    assert_equal "Unable to unsubscribe.", flash[:alert]
  end
end
