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

  belongs_to :assignment, touch: true
  belongs_to :teacher, optional: true, touch: true

  has_and_belongs_to_many :skills
  has_many :comments, as: :annotation
  has_rich_text :description
  has_rich_text :student_journal
  has_rich_text :teacher_journal
  has_one_attached :lesson_video
  has_one_attached :video_thumbnail
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  before_validation :assign_default_name, on: :create
  before_create :assign_sort_position
  before_create :assign_default_date
  before_create :assign_default_teacher

  validates_presence_of :name
  # validates_presence_of :lesson_video
  # validate :lesson_video_is_video_type

  delegate :existing_description_attachments, to: :assignment
  delegate :contributors, to: :assignment

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def meta_description
    if description.present? && description.to_plain_text.present?
      description.to_plain_text.truncate(160)
    elsif assignment.present? && assignment.description.present?
      assignment.description.to_plain_text.truncate(160)
    else
      "Lesson #{name}"
    end
  end

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

  def generate_video_thumbnail
    require "vips"

    title = name
    subtitle = "#{assignment.project_name}"
    teacher_name = teacher&.name || ""
    lesson_date = date&.strftime("%b %d, %Y") || ""

    svg = <<~SVG
      <svg width="1200" height="630" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#1f2937"/>
        <text x="50%" y="35%" dominant-baseline="middle" text-anchor="middle" fill="white" font-family="Arial, Helvetica, sans-serif" font-size="60" font-weight="bold">
          #{CGI.escapeHTML(title)}
        </text>
        <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="40">
          #{CGI.escapeHTML(subtitle)}
        </text>
        <text x="50%" y="60%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="30">
          #{CGI.escapeHTML(teacher_name)}
        </text>
        <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="30">
          #{CGI.escapeHTML(lesson_date)}
        </text>
      </svg>
    SVG

    image = Vips::Image.new_from_buffer(svg, "")

    Tempfile.create([ "thumbnail", ".png" ]) do |file|
      image.write_to_file(file.path)
      video_thumbnail.attach(io: File.open(file.path), filename: "thumbnail.png", content_type: "image/png")
    end
  end

  def project
    assignment
  end

  after_create :notify_subscribers
  after_create_commit :regenerate_assignment_thumbnail
  after_destroy_commit :regenerate_assignment_thumbnail
  after_update_commit :regenerate_assignment_thumbnail, if: :saved_change_to_date?
  after_commit :update_teacher_assignments_count
  after_commit :update_student_lessons_count

  def notify_subscribers
    assignment.subscribers.each do |user|
      ProjectMailer.new_lesson_notification(user, self).deliver_later
    end
  end

  def regenerate_assignment_thumbnail
    GenerateVideoThumbnailJob.perform_later(assignment) if assignment
  end

  after_save :enqueue_thumbnail_generation, if: :saved_change_to_thumbnail_attributes?

  def saved_change_to_thumbnail_attributes?
    saved_change_to_name? || saved_change_to_teacher_id? || saved_change_to_date?
  end

  def enqueue_thumbnail_generation
    GenerateLessonThumbnailJob.set(wait: 1.minute).perform_later(self, {
      name: name,
      teacher_id: teacher_id,
      date: date&.to_s
    })
  end

  def update_teacher_assignments_count
    if destroyed?
      teacher&.update_assignments_count
    elsif saved_change_to_teacher_id?
      Teacher.find_by(id: teacher_id_before_last_save)&.update_assignments_count
      teacher&.update_assignments_count
    else
      teacher&.update_assignments_count
    end
  end

  def update_student_lessons_count
    if destroyed?
      assignment&.student&.update_lessons_count
    elsif saved_change_to_assignment_id?
      if assignment_id_before_last_save
        old_assignment = Assignment.find_by(id: assignment_id_before_last_save)
        old_assignment&.student&.update_lessons_count
      end
      assignment&.student&.update_lessons_count
    else
      assignment&.student&.update_lessons_count
    end
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
