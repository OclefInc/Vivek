# Active Storage Configuration for Better Video Streaming

Rails.application.config.to_prepare do
  # Enable streaming for video files
  ActiveStorage::Blob.class_eval do
    # Override url method to add streaming-friendly parameters for videos
    alias_method :original_url, :url unless method_defined?(:original_url)

    def url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :attachment, **options)
      if video? && service_name == :amazon
        # For S3 videos, use inline disposition for streaming and longer expiration
        disposition = :inline
        expires_in = 2.hours
      end

      original_url(expires_in: expires_in, disposition: disposition, **options)
    end
  end
end
