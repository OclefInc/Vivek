if ENV["CLOUDFRONT_DOMAIN"].present?
  Rails.application.config.to_prepare do
    ActiveStorage::Blob.class_eval do
      def url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :attachment, **options)
        # Use CloudFront domain instead of S3
        "https://#{ENV['CLOUDFRONT_DOMAIN']}/#{key}"
      end
    end
  end
end
