require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
    @user.update(magic_link_token: "test_token")
  end

  test "login_link" do
    email = MagicLinkMailer.login_link(@user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_equal [ "info@oclef.com" ], email.from
    assert_equal "Your login link for #{ENV.fetch('APP_NAME', 'Vivek')}", email.subject
    assert_match @user.magic_link_token, email.body.encoded
  end
end
