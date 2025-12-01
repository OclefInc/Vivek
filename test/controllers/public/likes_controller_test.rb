require "test_helper"

class Public::LikesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @like = likes(:one)
    @like.update(user: @user)
    @likeable = @like.likeable
  end

  test "should create like" do
    sign_in @user
    @like.destroy

    assert_difference("Like.count") do
      post likes_path, params: { like: { likeable_id: @likeable.id, likeable_type: @likeable.class.name } }
    end

    assert_redirected_to root_path
  end

  test "should destroy like" do
    sign_in @user
    assert_difference("Like.count", -1) do
      delete like_path(@like)
    end

    assert_redirected_to root_path
  end
end
