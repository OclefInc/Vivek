# == Schema Information
#
# Table name: tutorials
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  teacher_id :bigint           not null
#
# Indexes
#
#  index_tutorials_on_teacher_id  (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (teacher_id => teachers.id)
#
class Tutorial < ApplicationRecord
  belongs_to :teacher
  has_one_attached :video_file
  has_rich_text :description

  before_validation :assign_default_name, on: :create

  validates_presence_of :name

  def views
  end

  private
    def assign_default_name
      # set name to date if name is blank
      self.name = Date.today.to_s if name.blank? && video_file.attached?
    end
end
