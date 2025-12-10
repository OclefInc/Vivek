# == Schema Information
#
# Table name: journals
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  composition_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_journals_on_composition_id  (composition_id)
#  index_journals_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (composition_id => compositions.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class JournalTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @journal = journals(:one)
    @user = users(:one)
    @composition = compositions(:one)
  end

  test "delegates name to composition" do
    assert_equal @journal.composition.name, @journal.name
  end

  test "to_param returns id-composition_name-user_name" do
    journal = Journal.create!(composition: @composition, user: @user)
    expected = "#{journal.id}-#{@composition.name.parameterize}-#{@user.name.parameterize}"
    assert_equal expected, journal.to_param
  end

  test "first_journal_entry returns first entry by sort order" do
    journal = Journal.create!(composition: @composition, user: @user)
    entry1 = journal.journal_entries.create!(name: "Entry 1", date: Date.today, sort: 1)
    entry2 = journal.journal_entries.create!(name: "Entry 2", date: Date.today, sort: 2)

    assert_equal entry1, journal.reload.first_journal_entry
  end

  test "generate_video_thumbnail with journal entries" do
    journal = Journal.create!(composition: @composition, user: @user)
    journal.journal_entries.create!(name: "Entry 1", date: Date.today - 5, sort: 1)
    journal.journal_entries.create!(name: "Entry 2", date: Date.today, sort: 2)

    # Stub complete? method
    journal.stubs(:complete?).returns(true)

    # Mock Vips::Image to avoid actual image processing
    require "vips"
    mock_image = mock("image")
    mock_image.expects(:write_to_file).once
    Vips::Image.expects(:new_from_buffer).returns(mock_image)

    # Mock the attachment
    journal.video_thumbnail.expects(:attach).once

    journal.generate_video_thumbnail
  end

  test "generate_video_thumbnail without journal entries" do
    journal = Journal.create!(composition: @composition, user: @user)

    # Mock Vips::Image to avoid actual image processing
    require "vips"
    mock_image = mock("image")
    mock_image.expects(:write_to_file).once
    Vips::Image.expects(:new_from_buffer).returns(mock_image)

    # Mock the attachment
    journal.video_thumbnail.expects(:attach).once

    journal.generate_video_thumbnail
  end

  test "generate_video_thumbnail with incomplete journal" do
    journal = Journal.create!(composition: @composition, user: @user)
    journal.journal_entries.create!(name: "Entry 1", date: Date.today, sort: 1)

    # Stub complete? to return false
    journal.stubs(:complete?).returns(false)

    # Mock Vips::Image to avoid actual image processing
    require "vips"
    mock_image = mock("image")
    mock_image.expects(:write_to_file).once
    Vips::Image.expects(:new_from_buffer).with { |svg_content, _|
      svg_content.include?("In Progress")
    }.returns(mock_image)

    # Mock the attachment
    journal.video_thumbnail.expects(:attach).once

    journal.generate_video_thumbnail
  end


  test "enqueues thumbnail generation after save when summary video changes" do
    journal = Journal.create!(composition: @composition, user: @user)

    # Stub the method to return true
    journal.stubs(:saved_change_to_summary_video_attachment?).returns(true)

    assert_enqueued_with(job: GenerateVideoThumbnailJob) do
      journal.save
    end
  end

  test "increments teacher journals_count when journal is created" do
    user = users(:one)
    teacher = Teacher.create!(name: "Test Teacher", user: user)

    initial_count = teacher.journals_count

    journal = Journal.create!(composition: @composition, user: user)
    teacher.reload

    assert_equal initial_count + 1, teacher.journals_count
  end

  test "decrements teacher journals_count when journal is destroyed" do
    user = users(:one)
    teacher = Teacher.create!(name: "Test Teacher", user: user)
    journal = Journal.create!(composition: @composition, user: user)

    teacher.reload
    count_before = teacher.journals_count

    journal.destroy
    teacher.reload

    assert_equal count_before - 1, teacher.journals_count
  end

  test "does not crash when user has no teacher on journal create" do
    user = users(:two) # User without teacher

    assert_nothing_raised do
      Journal.create!(composition: @composition, user: user)
    end
  end
end
