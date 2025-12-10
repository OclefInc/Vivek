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
  # test "the truth" do
  #   assert true
  # end
end
