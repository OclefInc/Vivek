# == Schema Information
#
# Table name: assignments
#
#  id              :bigint           not null, primary key
#  composition     :string
#  project_name    :string
#  student         :string
#  student_age     :integer
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
  belongs_to :student, touch: true, counter_cache: true
  belongs_to :project_type, touch: true

  belongs_to :teacher, optional: true # use for default teacher when uploading new lesson videos
  validates :project_name, presence: true
  has_many :lessons
  has_many :teachers, through: :lessons
  has_rich_text :description
  has_one_attached :summary_video
  has_one_attached :video_thumbnail
  has_many :comments, as: :annotation
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  def vip_users
    ([ student&.user ] + teachers.map(&:user)).uniq.compact
  end

  def to_param
    "#{id}-#{project_name.parameterize}-#{student.name.parameterize}"
  end

  def meta_description
    if description.present? && description.to_plain_text.present?
      description.to_plain_text.truncate(160)
    else
      "Project: #{project_name} (#{student.name})"
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

  def generate_video_thumbnail
    require "vips"

    title = composition.name
    subtitle = student.name

    if lessons.any?
      start_date = lessons.minimum(:date)&.strftime("%b %d, %Y")
      end_date = lessons.maximum(:date)&.strftime("%b %d, %Y")
      count = lessons.count
      lesson_count_text = "#{count} #{'Lesson'.pluralize(count)}"
      if !complete?
        lesson_count_text += " (In Progress)"
      end
      date_range_text = "#{start_date} - #{end_date}"
    else
      lesson_count_text = ""
      date_range_text = ""
    end

    svg = <<~SVG
      <svg width="1200" height="630" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#1f2937"/>
        <text x="50%" y="35%" dominant-baseline="middle" text-anchor="middle" fill="white" font-family="Arial, Helvetica, sans-serif" font-size="60" font-weight="bold">
          #{CGI.escapeHTML(title)}
        </text>
        <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="40">
          #{CGI.escapeHTML(subtitle)}
        </text>
        <text x="50%" y="65%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="35">
          #{CGI.escapeHTML(lesson_count_text)}
        </text>
        <text x="50%" y="75%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="30">
          #{CGI.escapeHTML(date_range_text)}
        </text>
      </svg>
    SVG

    image = Vips::Image.new_from_buffer(svg, "")

    Tempfile.create([ "thumbnail", ".png" ]) do |file|
      image.write_to_file(file.path)
      video_thumbnail.attach(io: File.open(file.path), filename: "thumbnail.png", content_type: "image/png")
    end
  end

  after_save :enqueue_thumbnail_generation, if: :saved_change_to_summary_video_attachment?

  def saved_change_to_summary_video_attachment?
    attachment_changes["summary_video"].present?
  end

  def enqueue_thumbnail_generation
    GenerateAssignmentThumbnailJob.perform_later(self)
  end
end
