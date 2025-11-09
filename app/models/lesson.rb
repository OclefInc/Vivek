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



    def complete?
      description.present? &&
      student_journal.present? &&
      teacher_journal.present?
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

    def lesson_video_is_video_type
        unless lesson_video.content_type.starts_with?("video/")
          errors.add(:lesson_video, "must be a video file")
        end
    end

    def project
      assignment
    end

    def existing_description_attachments
      return [] unless assignment.present?

      # Get all lessons in the same assignment (no eager loading needed for has_rich_text)
      blobs = assignment.lessons.order(:sort).flat_map do |lesson|
        next [] unless lesson.description.body.present?

        # Get all attachments from the lesson's description
        lesson.description.body.attachments.map do |attachment|
          # Skip attachments that were derived (reused from dropdown)
          next if attachment.metadata["derived"] == "true"

          # ActionText::Attachment has attachable which returns the blob
          blob = attachment.attachable
          next unless blob.is_a?(ActiveStorage::Blob)

          {
            blob: blob,
            created_at: blob.created_at,
            sgid: blob.attachable_sgid,
            filename: blob.filename.to_s,
            lesson_name: lesson.name,
            lesson_id: lesson.id,
            description_copyrighted: blob.metadata["copyrighted"] == true,
            description_purchase_url: blob.metadata["purchase_url"]
          }
        end
      end.compact
      # find duplicates by sgid, keep the oldest on
      unique_blobs = {}
      blobs.each do |blob_info|
        sgid = blob_info[:sgid]
        if unique_blobs.key?(sgid)
          # If this blob is older, replace the existing one
          if blob_info[:created_at] < unique_blobs[sgid][:created_at]
            unique_blobs[sgid] = blob_info
          end
        else
          unique_blobs[sgid] = blob_info
        end
      end
      unique_blobs.values
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
