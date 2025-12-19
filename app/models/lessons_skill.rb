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
class LessonsSkill < ApplicationRecord
  belongs_to :lesson
  belongs_to :skill
end
