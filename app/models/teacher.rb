# == Schema Information
#
# Table name: teachers
#
#  id         :bigint           not null, primary key
#  city       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
class Teacher < ApplicationRecord
  has_many :tutorials
  has_many :skill_categories, through: :tutorials
  has_many :lessons
  has_many :assignments, through: :lessons
  has_one_attached :profile_picture
  has_rich_text :bio
  belongs_to :user, optional: true
  validates_presence_of :name

  after_save :touch_assignments

  def projects
    assignments.uniq
  end

  private

    def touch_assignments
      # Touch all assignments where this teacher taught a lesson to bust cache
      assignments.distinct.find_each(&:touch)
    end
end
