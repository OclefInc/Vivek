require "test_helper"

class GenerateJournalEntryThumbnailJobTest < ActiveJob::TestCase
  test "calls generate_video_thumbnail when attributes match" do
    journal_entry = journal_entries(:one)
    expected_attributes = {
      "name" => journal_entry.name,
      "date" => journal_entry.date&.to_s
    }

    # Expect generate_video_thumbnail to be called
    journal_entry.expects(:generate_video_thumbnail).once

    GenerateJournalEntryThumbnailJob.perform_now(journal_entry, expected_attributes)
  end

  test "does not call generate_video_thumbnail when attributes do not match" do
    journal_entry = journal_entries(:one)
    expected_attributes = {
      "name" => "Different Name",
      "date" => journal_entry.date&.to_s
    }

    # Expect generate_video_thumbnail NOT to be called
    journal_entry.expects(:generate_video_thumbnail).never

    GenerateJournalEntryThumbnailJob.perform_now(journal_entry, expected_attributes)
  end

  test "does not call generate_video_thumbnail when journal_entry is nil" do
    expected_attributes = {
      "name" => "Some Name",
      "date" => Date.today.to_s
    }

    # Should not raise an error
    assert_nothing_raised do
      GenerateJournalEntryThumbnailJob.perform_now(nil, expected_attributes)
    end
  end
end
