# == Schema Information
#
# Table name: chapters
#
#  id         :bigint           not null, primary key
#  name       :string
#  start_time :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lesson_id  :bigint           not null
#
# Indexes
#
#  index_chapters_on_lesson_id                 (lesson_id)
#  index_chapters_on_lesson_id_and_start_time  (lesson_id,start_time)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#
require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
