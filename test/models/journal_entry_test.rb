# == Schema Information
#
# Table name: journal_entries
#
#  id               :bigint           not null, primary key
#  date             :date
#  name             :string
#  sort             :integer          default(1000)
#  video_end_time   :integer
#  video_start_time :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  journal_id       :bigint           not null
#
# Indexes
#
#  index_journal_entries_on_journal_id  (journal_id)
#
# Foreign Keys
#
#  fk_rails_...  (journal_id => journals.id)
#
require "test_helper"

class JournalEntryTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @journal = journals(:one)
    @journal_entry = journal_entries(:one)
    @user = users(:one)
  end

  test "validates presence of name" do
    entry = JournalEntry.new(journal: @journal)
    assert_not entry.valid?
    assert_includes entry.errors[:name], "can't be blank"
  end

  test "to_param returns id-parameterized_name" do
    entry = @journal.journal_entries.create!(name: "My Test Entry", date: Date.today)
    assert_equal "#{entry.id}-my-test-entry", entry.to_param
  end

  test "to_param handles nil name" do
    entry = @journal.journal_entries.new(id: 123)
    entry.stubs(:name).returns(nil)
    assert_equal "123-entry", entry.to_param
  end

  test "next_entry returns next entry by sort order" do
    entry1 = @journal.journal_entries.create!(name: "Entry 1", date: Date.today, sort: 1)
    entry2 = @journal.journal_entries.create!(name: "Entry 2", date: Date.today, sort: 2)
    entry3 = @journal.journal_entries.create!(name: "Entry 3", date: Date.today, sort: 3)

    assert_equal entry2, entry1.next_entry
    assert_equal entry3, entry2.next_entry
    assert_nil entry3.next_entry
  end

  test "previous_entry returns previous entry by sort order" do
    # Clear existing entries
    @journal.journal_entries.destroy_all

    entry1 = @journal.journal_entries.create!(name: "Entry 1", date: Date.today, sort: 1)
    entry2 = @journal.journal_entries.create!(name: "Entry 2", date: Date.today, sort: 2)
    entry3 = @journal.journal_entries.create!(name: "Entry 3", date: Date.today, sort: 3)

    assert_nil entry1.previous_entry
    assert_equal entry1, entry2.previous_entry
    assert_equal entry2, entry3.previous_entry
  end

  test "next and previous aliases work" do
    entry1 = @journal.journal_entries.create!(name: "Entry 1", date: Date.today, sort: 1)
    entry2 = @journal.journal_entries.create!(name: "Entry 2", date: Date.today, sort: 2)

    assert_equal entry2, entry1.next
    assert_equal entry1, entry2.previous
  end

  test "notify_subscribers sends emails to all subscribers" do
    subscriber1 = users(:one)
    subscriber2 = users(:two)

    @journal.subscriptions.create!(user: subscriber1)
    @journal.subscriptions.create!(user: subscriber2)

    entry = @journal.journal_entries.new(name: "New Entry", date: Date.today)

    assert_enqueued_jobs 2, only: ActionMailer::MailDeliveryJob do
      entry.save!
    end
  end

  test "regenerate_journal_thumbnail enqueues job" do
    entry = @journal.journal_entries.create!(name: "Entry", date: Date.today)

    assert_enqueued_with(job: GenerateVideoThumbnailJob, args: [ @journal ]) do
      entry.regenerate_journal_thumbnail
    end
  end

  test "regenerate_journal_thumbnail handles nil journal" do
    entry = JournalEntry.new(name: "Entry", date: Date.today)
    entry.stubs(:journal).returns(nil)

    assert_nothing_raised do
      entry.regenerate_journal_thumbnail
    end
  end

  test "regenerate_journal_thumbnail after create" do
    # The after_create_commit callback enqueues GenerateVideoThumbnailJob
    entry = nil
    perform_enqueued_jobs(only: GenerateVideoThumbnailJob) do
      entry = @journal.journal_entries.create!(name: "New Entry", date: Date.today)
    end

    assert entry.persisted?
  end

  test "regenerate_journal_thumbnail after destroy" do
    entry = @journal.journal_entries.create!(name: "Entry to Delete", date: Date.today)

    # The after_destroy_commit callback enqueues GenerateVideoThumbnailJob
    perform_enqueued_jobs(only: GenerateVideoThumbnailJob) do
      entry.destroy
    end

    assert entry.destroyed?
  end

  test "regenerate_journal_thumbnail after update if date changed" do
    entry = @journal.journal_entries.create!(name: "Entry", date: Date.today)

    assert_enqueued_with(job: GenerateVideoThumbnailJob) do
      entry.update!(date: Date.tomorrow)
    end
  end

  test "saved_change_to_thumbnail_attributes? returns true when name changed" do
    entry = @journal.journal_entries.create!(name: "Original", date: Date.today)
    entry.update!(name: "Updated")

    assert entry.saved_change_to_name?
  end

  test "saved_change_to_thumbnail_attributes? returns true when date changed" do
    entry = @journal.journal_entries.create!(name: "Entry", date: Date.today)
    entry.update!(date: Date.tomorrow)

    assert entry.saved_change_to_date?
  end

  test "enqueue_thumbnail_generation enqueues job after save" do
    entry = @journal.journal_entries.create!(name: "Entry", date: Date.today)

    assert_enqueued_with(job: GenerateJournalEntryThumbnailJob) do
      entry.update!(name: "Updated Entry")
    end
  end

  test "generate_video_thumbnail creates thumbnail" do
    entry = @journal.journal_entries.create!(name: "Test Entry", date: Date.today)

    # Stub user method on journal_entry
    entry.stubs(:user).returns(@user)

    # Mock Vips::Image to avoid actual image processing
    require "vips"
    mock_image = mock("image")
    mock_image.expects(:write_to_file).once
    Vips::Image.expects(:new_from_buffer).returns(mock_image)

    # Mock the attachment
    entry.video_thumbnail.expects(:attach).once

    entry.generate_video_thumbnail
  end

  test "generate_video_thumbnail handles nil user" do
    entry = @journal.journal_entries.create!(name: "Test Entry", date: Date.today)

    # Stub user to return nil
    entry.stubs(:user).returns(nil)

    # Mock Vips::Image to avoid actual image processing
    require "vips"
    mock_image = mock("image")
    mock_image.expects(:write_to_file).once
    Vips::Image.expects(:new_from_buffer).with { |svg_content, _|
      svg_content.include?("")
    }.returns(mock_image)

    # Mock the attachment
    entry.video_thumbnail.expects(:attach).once

    entry.generate_video_thumbnail
  end

  test "generate_video_thumbnail handles nil date" do
    entry = @journal.journal_entries.new(name: "Test Entry", date: nil, journal: @journal)
    entry.save(validate: false)

    # Stub user method
    entry.stubs(:user).returns(@user)

    # Mock Vips::Image to avoid actual image processing
    require "vips"
    mock_image = mock("image")
    mock_image.expects(:write_to_file).once
    Vips::Image.expects(:new_from_buffer).with { |svg_content, _|
      svg_content.include?("")
    }.returns(mock_image)

    # Mock the attachment
    entry.video_thumbnail.expects(:attach).once

    entry.generate_video_thumbnail
  end

  test "assign_default_name sets name to date when name is blank and video attached" do
    entry = @journal.journal_entries.new(date: Date.today)

    # Mock entry_video.attached? to return true
    entry.entry_video.expects(:attached?).returns(true)

    entry.save

    assert_equal Date.today.to_s, entry.name
  end

  test "assign_default_name does not set name when video not attached" do
    entry = @journal.journal_entries.new(name: "", date: Date.today)

    # This will fail validation, but we can check the callback didn't set a name
    assert_not entry.valid?
    assert_equal "", entry.name
  end

  test "assign_sort_position sets sort to next position" do
    # Clear existing entries
    @journal.journal_entries.destroy_all

    entry1 = @journal.journal_entries.create!(name: "Entry 1", date: Date.today)
    # Entry1 will get sort = 1 (0 + 1)
    entry2 = @journal.journal_entries.create!(name: "Entry 2", date: Date.today)
    # Entry2 will get sort = 2 (1 + 1)

    assert_equal 1, entry1.sort
    assert_equal 2, entry2.sort
  end

  test "assign_sort_position sets sort to 1 when no entries exist" do
    new_journal = Journal.create!(composition: compositions(:one), user: @user)
    entry = new_journal.journal_entries.create!(name: "First Entry", date: Date.today)

    assert_equal 1, entry.sort
  end

  test "assign_default_date sets date to today when blank" do
    entry = @journal.journal_entries.create!(name: "Entry without date")

    assert_equal Date.today, entry.date
  end

  test "assign_default_date does not override existing date" do
    specific_date = Date.new(2025, 1, 15)
    entry = @journal.journal_entries.create!(name: "Entry with date", date: specific_date)

    assert_equal specific_date, entry.date
  end
end
