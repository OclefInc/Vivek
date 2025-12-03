# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_crop_height     :integer
#  avatar_crop_width      :integer
#  avatar_crop_x          :integer
#  avatar_crop_y          :integer
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  magic_link_sent_at     :datetime
#  magic_link_token       :string
#  name                   :string
#  picture_url            :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_magic_link_token      (magic_link_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should link existing user with omniauth" do
    user = users(:one)
    # Use update_columns to bypass Devise reconfirmable logic which would put the new email in unconfirmed_email
    user.update_columns(provider: nil, uid: nil, email: "existing@example.com")

    auth = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456789",
      info: {
        email: "existing@example.com",
        name: "Google User",
        image: "http://example.com/image.jpg"
      }
    })

    assert_no_difference "User.count" do
      omniauth_user = User.from_omniauth(auth)
      assert_equal user.id, omniauth_user.id
      assert_equal "google_oauth2", omniauth_user.provider
      assert_equal "123456789", omniauth_user.uid
      assert_equal "http://example.com/image.jpg", omniauth_user.picture_url
    end
  end

  test "should link existing user with github omniauth" do
    user = users(:two)
    user.update_columns(provider: nil, uid: nil, email: "github_user@example.com")

    auth = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "987654321",
      info: {
        email: "github_user@example.com",
        name: "GitHub User",
        image: "http://example.com/github_image.jpg"
      }
    })

    assert_no_difference "User.count" do
      omniauth_user = User.from_omniauth(auth)
      assert_equal user.id, omniauth_user.id
      assert_equal "github", omniauth_user.provider
      assert_equal "987654321", omniauth_user.uid
    end
  end

  test "should create new user if email does not match" do
    auth = OmniAuth::AuthHash.new({
      provider: "facebook",
      uid: "555555555",
      info: {
        email: "new_facebook@example.com",
        name: "Facebook User",
        image: "http://example.com/fb_image.jpg"
      }
    })

    assert_difference "User.count", 1 do
      omniauth_user = User.from_omniauth(auth)
      assert_equal "facebook", omniauth_user.provider
      assert_equal "new_facebook@example.com", omniauth_user.email
    end
  end

  test "should allow login with multiple providers for same email" do
    email = "multi_provider@example.com"
    user = User.create!(
      email: email,
      name: "Multi User",
      password: "password",
      provider: "google_oauth2",
      uid: "google_123"
    )

    # 1. Login with GitHub (same email)
    github_auth = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "github_456",
      info: {
        email: email,
        name: "GitHub User",
        image: "http://example.com/gh.jpg"
      }
    })

    assert_no_difference "User.count" do
      github_user = User.from_omniauth(github_auth)
      assert_equal user.id, github_user.id
      assert_equal "github", github_user.provider
      assert_equal "github_456", github_user.uid
    end

    # 2. Login with Google again
    google_auth = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "google_123",
      info: {
        email: email,
        name: "Google User",
        image: "http://example.com/google.jpg"
      }
    })

    assert_no_difference "User.count" do
      google_user = User.from_omniauth(google_auth)
      assert_equal user.id, google_user.id
      assert_equal "google_oauth2", google_user.provider
      assert_equal "google_123", google_user.uid
    end
  end
end
