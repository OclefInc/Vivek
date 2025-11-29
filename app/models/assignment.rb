# == Schema Information
#
# Table name: assignments
#
#  id              :bigint           not null, primary key
#  composition     :string
#  student         :string
#  teacher         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  composition_id  :integer
#  project_type_id :bigint
#  student_id      :integer
#  teacher_id      :integer
#
# Indexes
#
#  index_assignments_on_project_type_id  (project_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_type_id => project_types.id)
#
class Assignment < ApplicationRecord
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :composition
  belongs_to :project_type, optional: true

  has_many :lessons
  has_many :teachers, through: :lessons
  has_rich_text :description
  has_one_attached :summary_video
  has_many :comments, as: :annotation
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  def to_param
    "#{id}-#{composition.name.parameterize}-#{student.name.parameterize}"
  end

  def meta_description
    if description.present? && description.to_plain_text.present?
      description.to_plain_text.truncate(160)
    else
      "Project: #{name}"
    end
  end

  def complete?
    summary_video.attached? && lessons.exists?
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

  def first_lesson
    lessons.order(:sort).first
  end

  def existing_description_attachments
    # Get all lessons in the same assignment (no eager loading needed for has_rich_text)
    blobs = lessons.order(:sort).flat_map do |lesson|
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
end
