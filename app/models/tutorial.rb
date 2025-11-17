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
class Tutorial < ApplicationRecord
  include RailsSortable::Model

  set_sortable :sort  # Indicate a sort column

  belongs_to :teacher
  belongs_to :skill_category, optional: true
  has_many :chapters_tutorials, -> { order(:sort) }, dependent: :destroy
  has_many :chapters, through: :chapters_tutorials
  has_one_attached :video_file
  has_rich_text :description

  before_validation :assign_default_name, on: :create
  before_create :assign_sort_position

  validates_presence_of :name

  def views
  end

  private
    def assign_default_name
      # set name to date if name is blank
      self.name = Date.today.to_s if name.blank? && video_file.attached?
    end

    def assign_sort_position
      # Set sort to the next position after the last lesson in the assignment
      if teacher.present?
        max_sort = teacher.tutorials.maximum(:sort) || 0
        self.sort = max_sort + 1
      end
    end
end
