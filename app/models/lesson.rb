# == Schema Information
#
# Table name: lessons
#
#  id            :bigint           not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :integer
#
class Lesson < ApplicationRecord
    belongs_to :assignment
    validates_presence_of :name
    has_rich_text :description
    has_one_attached :lesson_video
end
