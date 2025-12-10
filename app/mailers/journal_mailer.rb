class JournalMailer < ApplicationMailer
  def new_journal_entry_notification(user, journal_entry)
    @user = user
    @journal_entry = journal_entry
    @journal = journal_entry.journal
    mail(to: @user.email, subject: "New Journal Entry Added: #{@journal.name}")
  end
end
