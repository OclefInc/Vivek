# == Schema Information
#
# Table name: lessons
#
#  id                       :bigint           not null, primary key
#  date                     :date
#  description_copyrighted  :boolean
#  description_purchase_url :string
#  name                     :string
#  sort                     :integer          default(1000)
#  video_end_time           :integer
#  video_start_time         :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assignment_id            :integer
#  teacher_id               :integer
#
class Lesson < ApplicationRecord
  has_many :chapters, -> { order(:start_time) }, dependent: :destroy
  include RailsSortable::Model

  set_sortable :sort  # Indicate a sort column

  belongs_to :assignment
  belongs_to :teacher, optional: true

  has_and_belongs_to_many :skills
  has_many :comments, as: :annotation
  has_rich_text :description
  has_rich_text :student_journal
  has_rich_text :teacher_journal
  has_one_attached :lesson_video

  before_validation :assign_default_name, on: :create
  before_create :assign_sort_position
  before_create :assign_default_date
  before_create :assign_default_teacher

  validates_presence_of :name
  # validates_presence_of :lesson_video
  # validate :lesson_video_is_video_type

  delegate :existing_description_attachments, to: :assignment

  def complete?
    teacher.present? && chapters.exists? && lesson_video.attached? && !description.blank?
  end

  def status
    if complete?
      "Complete"
    else
      "Incomplete"
    end
  end

  def next_lesson
    assignment.lessons.where("sort > ?", sort).order(:sort).first
  end

  def previous_lesson
    assignment.lessons.where("sort < ?", sort).order(sort: :desc).first
  end

  alias_method :next, :next_lesson
  alias_method :previous, :previous_lesson

  def update_all_chapter_stop_times
    # Get all chapters ordered by start_time
    ordered_chapters = chapters.order(:start_time).to_a

    # Update each chapter's stop_time to the next chapter's start_time
    ordered_chapters.each_with_index do |chapter, index|
      next_chapter = ordered_chapters[index + 1]

      if next_chapter
        chapter.update_column(:stop_time, next_chapter.start_time)
      else
        # Last chapter - set stop_time to nil or video end time
        chapter.update_column(:stop_time, nil)
      end
    end
  end

  def lesson_video_is_video_type
    unless lesson_video.content_type.starts_with?("video/")
      errors.add(:lesson_video, "must be a video file")
    end
  end

  def project
    assignment
  end

    private
      def assign_default_name
        # set name to date if name is blank
        self.name = Date.today.to_s if name.blank? && lesson_video.attached?
      end

      def assign_sort_position
        # Set sort to the next position after the last lesson in the assignment
        if assignment.present?
          max_sort = assignment.lessons.maximum(:sort) || 0
          self.sort = max_sort + 1
        end
      end

      def assign_default_date
        # Set date to today if not already set
        self.date = Date.today if date.blank?
      end

      def assign_default_teacher
        # Set teacher_id from assignment if not already set
        if assignment.present? && teacher_id.blank? && assignment.teacher_id.present?
          self.teacher_id = assignment.teacher_id
        end
      end
end
