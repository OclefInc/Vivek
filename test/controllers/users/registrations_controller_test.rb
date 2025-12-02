require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @user = users(:one)
    @image = fixture_file_upload("test/fixtures/files/test_image.png", "image/png")
  end

  test "should create user and send magic link" do
    assert_difference("User.count") do
      assert_emails 1 do
        post user_registration_path, params: {
          user: {
            email: "newuser@example.com",
            name: "New User"
          }
        }
      end
    end

    assert_redirected_to new_user_session_path
    assert_equal "Welcome! Check your email for a magic link to login.", flash[:notice]

    user = User.last
    assert_equal "newuser@example.com", user.email
    assert_equal "New User", user.name
    assert_not_nil user.magic_link_token
    assert_not_nil user.magic_link_sent_at
    # Password should be set automatically
    assert_not_nil user.encrypted_password
  end

  test "should create user with avatar" do
    assert_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "avataruser@example.com",
          name: "Avatar User",
          avatar: @image
        }
      }
    end

    user = User.last
    assert user.avatar.attached?
  end

  test "should not create user with invalid params" do
    assert_no_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "",
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle inactive user on create" do
    # Stub active_for_authentication? to return false to test the else branch
    # We need to use mocha or similar if available, or just subclass/stub.
    # Since we have mocha/minitest in test_helper.rb:

    User.any_instance.stubs(:active_for_authentication?).returns(false)
    User.any_instance.stubs(:inactive_message).returns(:unconfirmed)

    assert_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "inactive@example.com",
          name: "Inactive User"
        }
      }
    end

    # The controller uses after_inactive_sign_up_path_for(resource) which defaults to root_path or similar
    # We can check if it redirects to somewhere reasonable or just check response code if it's a redirect.
    assert_response :redirect
    # Flash message key: signed_up_but_unconfirmed
    assert_equal I18n.t("devise.registrations.signed_up_but_unconfirmed"), flash[:notice]
  end

  test "should update user without password" do
    sign_in @user

    patch user_registration_path, params: {
      user: {
        name: "Updated Name"
      }
    }

    assert_redirected_to edit_user_registration_path
    assert_equal "Profile updated successfully.", flash[:notice]
    @user.reload
    assert_equal "Updated Name", @user.name
  end

  test "should update user avatar" do
    sign_in @user

    patch user_registration_path, params: {
      user: {
        avatar: @image
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert @user.avatar.attached?
  end

  test "should update user with crop params" do
    sign_in @user

    patch user_registration_path, params: {
      user: {
        avatar_crop_x: 10,
        avatar_crop_y: 10,
        avatar_crop_width: 100,
        avatar_crop_height: 100
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert_equal 10, @user.avatar_crop_x
    assert_equal 100, @user.avatar_crop_width
  end

  test "should not update user with invalid params" do
    sign_in @user

    patch user_registration_path, params: {
      user: {
        email: "" # Email is required
      }
    }

    assert_response :unprocessable_entity
  end
end
