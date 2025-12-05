require "test_helper"
require "mocha/minitest"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:facebook] = nil
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.mock_auth[:apple] = nil
  end

  test "should authenticate with google_oauth2" do
    user = users(:one)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456789",
      info: {
        email: user.email,
        name: user.name,
        image: "http://example.com/image.jpg"
      }
    })

    get user_google_oauth2_omniauth_callback_url

    assert_redirected_to root_path
    assert_equal "Successfully authenticated from Google account.", flash[:notice]
  end

  test "should authenticate with facebook" do
    user = users(:one)

    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: "facebook",
      uid: "123456789",
      info: {
        email: user.email,
        name: user.name,
        image: "http://example.com/image.jpg"
      }
    })

    get user_facebook_omniauth_callback_url

    assert_redirected_to root_path
    assert_equal "Successfully authenticated from Facebook account.", flash[:notice]
  end

  test "should authenticate with github" do
    user = users(:one)

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123456789",
      info: {
        email: user.email,
        name: user.name,
        image: "http://example.com/image.jpg"
      }
    })

    get user_github_omniauth_callback_url

    assert_redirected_to root_path
    assert_equal "Successfully authenticated from GitHub account.", flash[:notice]
  end

  test "should authenticate with apple" do
    user = users(:one)

    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new({
      provider: "apple",
      uid: "123456789",
      info: {
        email: user.email,
        name: user.name,
        image: "http://example.com/image.jpg"
      }
    })

    get user_apple_omniauth_callback_url

    assert_redirected_to root_path
    assert_equal "Successfully authenticated from Apple account.", flash[:notice]
  end

  test "should handle failure" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    # Silence OmniAuth logger
    previous_logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new(nil)

    begin
      get user_google_oauth2_omniauth_callback_url
    ensure
      OmniAuth.config.logger = previous_logger
    end

    assert_redirected_to new_user_session_path
    assert_equal "Authentication failed. Please try again.", flash[:alert]
  end

  test "should handle unpersisted user" do
    user = User.new
    User.stubs(:from_omniauth).returns(user)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456789",
      info: {
        email: "test@example.com",
        name: "Test User"
      }
    })

    get user_google_oauth2_omniauth_callback_url

    assert_redirected_to new_user_registration_url
    assert_equal "There was a problem signing you in through Google. Please try again.", flash[:alert]
    assert_not_nil session["devise.google_data"]
  end
end
