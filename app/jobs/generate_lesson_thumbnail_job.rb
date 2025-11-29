class GenerateLessonThumbnailJob < ApplicationJob
  queue_as :default

  def perform(lesson, expected_attributes)
    return unless lesson

    # Check if the lesson attributes still match what we expect
    # If they don't, it means the lesson has been updated again,
    # and a newer job should have been enqueued.
    current_attributes = {
      "name" => lesson.name,
      "teacher_id" => lesson.teacher_id,
      "date" => lesson.date&.to_s
    }

    if current_attributes != expected_attributes.stringify_keys
      return
    end

    lesson.generate_video_thumbnail
  end
end
