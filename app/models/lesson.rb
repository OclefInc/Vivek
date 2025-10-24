# == Schema Information
#
# Table name: lessons
#
#  id            :bigint           not null, primary key
#  name          :string
#  sort          :integer          default(1000)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :integer
#
class Lesson < ApplicationRecord
  include RailsSortable::Model
    set_sortable :sort  # Indicate a sort column

    belongs_to :assignment

    has_and_belongs_to_many :skills
    has_many :comments, as: :annotation
    has_rich_text :description
    has_rich_text :student_journal
    has_rich_text :teacher_journal
    has_one_attached :lesson_video

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

    def lesson_video_is_video_type
        unless lesson_video.content_type.starts_with?("video/")
          errors.add(:lesson_video, "must be a video file")
        end
    end

    def project
      assignment
    end
end
