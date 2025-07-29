# == Schema Information
#
# Table name: assignments
#
#  id             :bigint           not null, primary key
#  composition    :string
#  student        :string
#  teacher        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  composition_id :integer
#  student_id     :integer
#  teacher_id     :integer
#
class Assignment < ApplicationRecord
    has_many :lessons
    belongs_to :student
    belongs_to :teacher
    belongs_to :composition
    def name 
        "#{composition.name} (#{student.name})"
    end
end
