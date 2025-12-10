json.extract! journal_entry, :id, :name, :date, :journal_id, :video_start_time, :video_end_time, :created_at, :updated_at
json.url journal_journal_entry_url(journal_entry.journal, journal_entry, format: :json)
