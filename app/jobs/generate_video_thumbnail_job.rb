class GenerateVideoThumbnailJob < ApplicationJob
  queue_as :default

  def perform(model)
    model.generate_video_thumbnail
  end
end
