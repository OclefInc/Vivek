require "test_helper"

class GenerateVideoThumbnailJobTest < ActiveJob::TestCase
  test "calls generate_video_thumbnail on the assignment" do
    assignment = assignments(:one)

    # Expect generate_video_thumbnail to be called
    assignment.expects(:generate_video_thumbnail).once

    GenerateVideoThumbnailJob.perform_now(assignment)
  end
end
