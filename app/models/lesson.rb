# == Schema Information
#
# Table name: lessons
#
#  id            :bigint           not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :integer
#
class Lesson < ApplicationRecord
    belongs_to :assignment
    validates_presence_of :name
    has_rich_text :description
    has_one_attached :lesson_video
    validates_presence_of :lesson_video
    validate :lesson_video_is_video_type
    has_and_belongs_to_many :skills

    def lesson_video_is_video_type
        unless lesson_video.content_type.starts_with?("video/")
          errors.add(:lesson_video, "must be a video file")
        end
    end
end
