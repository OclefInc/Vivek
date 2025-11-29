class GenerateAssignmentThumbnailJob < ApplicationJob
  queue_as :default

  def perform(assignment)
    assignment.generate_video_thumbnail
  end
end
