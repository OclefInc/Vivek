# == Schema Information
#
# Table name: skills
#
#  id                :bigint           not null, primary key
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  skill_category_id :integer
#
class Skill < ApplicationRecord
  belongs_to :skill_category, optional: true
  has_and_belongs_to_many :lessons
end
