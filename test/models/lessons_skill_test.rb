# == Schema Information
#
# Table name: lessons_skills
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lesson_id  :integer
#  skill_id   :integer
#
require "test_helper"

class LessonsSkillTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
