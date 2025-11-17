# == Schema Information
#
# Table name: tutorials
#
#  id                :bigint           not null, primary key
#  name              :string
#  sort              :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  skill_category_id :bigint
#  teacher_id        :bigint           not null
#
# Indexes
#
#  index_tutorials_on_skill_category_id  (skill_category_id)
#  index_tutorials_on_teacher_id         (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (skill_category_id => skill_categories.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
require "test_helper"

class TutorialTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
