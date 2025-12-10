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
  # test "the truth" do
  #   assert true
  # end
end
