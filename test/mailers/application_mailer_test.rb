require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "default from email" do
    assert_equal "info@oclef.com", ApplicationMailer.default[:from]
  end
end
