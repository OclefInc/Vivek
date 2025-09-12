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
    has_rich_text :description
    has_one_attached :summary_video
    has_many :comments, as: :annotation

    def complete?
      !lessons.map{|lesson| lesson.complete?}.any?(false)
    end

    def status
      if complete?
        "Complete"
      else 
        "Incomplete"
      end
    end

    def name
        "#{composition.name} (#{student.name})"
    end
end
