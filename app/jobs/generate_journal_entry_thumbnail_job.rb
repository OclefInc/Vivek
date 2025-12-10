class GenerateJournalEntryThumbnailJob < ApplicationJob
  queue_as :default

  def perform(journal_entry, expected_attributes)
    return unless journal_entry
    # Check if the lesson attributes still match what we expect
    # If they don't, it means the lesson has been updated again,
    # and a newer job should have been enqueued.
    current_attributes = {
      "name" => journal_entry.name,
      "date" => journal_entry.date&.to_s
    }

    if current_attributes != expected_attributes.stringify_keys
      return
    end

    journal_entry.generate_video_thumbnail
  end
end
