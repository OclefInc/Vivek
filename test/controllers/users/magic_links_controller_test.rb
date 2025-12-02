require "test_helper"

class Users::MagicLinksControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @user = users(:one)
    @oauth_user = users(:two)
    @oauth_user.update!(provider: "google_oauth2", uid: "123456")
  end

  test "should send magic link for regular user" do
    assert_emails 1 do
      post users_magic_links_path, params: { email: @user.email }
    end

    assert_redirected_to new_user_session_path
    assert_equal "Check your email for a login link!", flash[:notice]

    @user.reload
    assert_not_nil @user.magic_link_token
    assert_not_nil @user.magic_link_sent_at
  end

  test "should show development link in development environment" do
    Rails.env.stubs(:development?).returns(true)

    assert_emails 0 do
      post users_magic_links_path, params: { email: @user.email }
    end

    assert_redirected_to new_user_session_path
    @user.reload
    expected_link = users_magic_link_url(token: @user.magic_link_token)
    assert_match expected_link, flash[:notice]
  end

  test "should not send magic link for oauth user" do
    assert_emails 0 do
      post users_magic_links_path, params: { email: @oauth_user.email }
    end

    assert_redirected_to new_user_session_path
    assert_equal "Please use Google Oauth2 to sign in.", flash[:alert]
  end

  test "should handle non-existent email" do
    assert_emails 0 do
      post users_magic_links_path, params: { email: "nonexistent@example.com" }
    end

    assert_redirected_to new_user_session_path
    assert_equal "If that email exists, we sent you a login link.", flash[:notice]
  end

  test "should login with valid token" do
    @user.generate_magic_link_token!
    token = @user.magic_link_token

    get users_magic_link_path(token: token)

    assert_redirected_to root_path # Assuming after_sign_in_path_for defaults to root or similar
    assert_equal "Successfully logged in!", flash[:notice]

    @user.reload
    assert_nil @user.magic_link_token
    assert_nil @user.magic_link_sent_at
    assert @controller.user_signed_in?
  end

  test "should confirm unconfirmed user on login" do
    @user.update!(confirmed_at: nil)
    @user.generate_magic_link_token!

    get users_magic_link_path(token: @user.magic_link_token)

    @user.reload
    assert @user.confirmed?
    assert @controller.user_signed_in?
  end

  test "should fail with invalid token" do
    get users_magic_link_path(token: "invalid_token")

    assert_redirected_to new_user_session_path
    assert_equal "Invalid or expired login link. Please request a new one.", flash[:alert]
    assert_not @controller.user_signed_in?
  end

  test "should fail with expired token" do
    @user.generate_magic_link_token!
    @user.update!(magic_link_sent_at: 20.minutes.ago)

    get users_magic_link_path(token: @user.magic_link_token)

    assert_redirected_to new_user_session_path
    assert_equal "Invalid or expired login link. Please request a new one.", flash[:alert]
    assert_not @controller.user_signed_in?
  end
end
