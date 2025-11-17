# == Schema Information
#
# Table name: chapters
#
#  id         :bigint           not null, primary key
#  name       :string
#  start_time :integer
#  stop_time  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lesson_id  :bigint           not null
#
# Indexes
#
#  index_chapters_on_lesson_id                 (lesson_id)
#  index_chapters_on_lesson_id_and_start_time  (lesson_id,start_time)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#
class Chapter < ApplicationRecord
  belongs_to :lesson, touch: true
  has_many :chapters_tutorials, dependent: :destroy
  has_many :tutorials, through: :chapters_tutorials

  validates :name, presence: true
  validates :start_time, presence: true, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:start_time) }

  after_create :update_previous_chapter_stop_time
  after_save :touch_assignment
  after_destroy :touch_assignment

  private

    def update_previous_chapter_stop_time
      # Find the previous chapter in the same lesson
      previous_chapter = lesson.chapters.unscoped
                               .where("start_time < ?", start_time)
                               .order(start_time: :desc)
                               .first

      # Update its stop_time to this chapter's start_time
      if previous_chapter
        previous_chapter.update_column(:stop_time, start_time)
      end
    end

    def touch_assignment
      lesson.assignment.touch if lesson.assignment
    end
end
