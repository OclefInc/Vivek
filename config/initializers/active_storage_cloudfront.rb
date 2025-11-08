if ENV["CLOUDFRONT_DOMAIN"].present?
  Rails.application.config.to_prepare do
    # Override blob URL generation to use CloudFront
    ActiveStorage::Blob.class_eval do
      def url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :attachment, **options)
        # Use CloudFront domain instead of S3
        "https://#{ENV['CLOUDFRONT_DOMAIN']}/#{key}"
      end
    end

    # Override the redirect controller to serve CloudFront URLs directly
    ActiveStorage::Blobs::RedirectController.class_eval do
      def show
        expires_in ActiveStorage.service_urls_expire_in, public: true
        redirect_to "https://#{ENV['CLOUDFRONT_DOMAIN']}/#{@blob.key}",
                    allow_other_host: true,
                    status: :moved_permanently
      end
    end
  end
end
