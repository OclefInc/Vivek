require "test_helper"

class JournalMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
    @journal = journals(:one)
    @journal_entry = journal_entries(:one)
  end

  test "new_journal_entry_notification" do
    email = JournalMailer.new_journal_entry_notification(@user, @journal_entry)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_equal [ "info@oclef.com" ], email.from
    assert_equal "New Journal Entry Added: #{@journal.name}", email.subject
    assert_match @journal_entry.name, email.body.encoded
  end
end
