require "test_helper"

class GenerateLessonThumbnailJobTest < ActiveJob::TestCase
  test "calls generate_video_thumbnail when attributes match" do
    lesson = lessons(:one)
    expected_attributes = {
      "name" => lesson.name,
      "teacher_id" => lesson.teacher_id,
      "date" => lesson.date&.to_s
    }

    # Expect generate_video_thumbnail to be called
    lesson.expects(:generate_video_thumbnail).once

    GenerateLessonThumbnailJob.perform_now(lesson, expected_attributes)
  end

  test "does not call generate_video_thumbnail when attributes do not match" do
    lesson = lessons(:one)
    expected_attributes = {
      "name" => "Different Name",
      "teacher_id" => lesson.teacher_id,
      "date" => lesson.date&.to_s
    }

    # Expect generate_video_thumbnail NOT to be called
    lesson.expects(:generate_video_thumbnail).never

    GenerateLessonThumbnailJob.perform_now(lesson, expected_attributes)
  end
end
