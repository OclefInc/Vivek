# Override ActiveStorage::Blob to include pages in Trix attachment JSON
Rails.application.config.to_prepare do
  ActiveStorage::Blob.class_eval do
    # Add pages data when converting blob to Trix attachment attributes
    alias_method :original_trix_attachment_attributes, :trix_attachment_attributes rescue nil

    def trix_attachment_attributes
      attrs = if respond_to?(:original_trix_attachment_attributes)
        original_trix_attachment_attributes
      else
        {
          sgid: attachable_sgid,
          content_type: content_type,
          filename: filename.to_s,
          filesize: byte_size,
          previewable: previewable?,
          url: url
        }
      end

      # Add pages from the stored data-pages attribute using the blob extension
      begin
        pages_value = data_pages
        attrs[:pages] = pages_value if pages_value.present?
      rescue => e
        # Log the error for debugging
        Rails.logger.error "Error getting data_pages for blob #{id}: #{e.message}"
        # If data_pages lookup fails, default to empty string
        attrs[:pages] = "" unless attrs.key?(:pages)
      end

      # Ensure pages key always exists
      attrs[:pages] ||= ""

      attrs
    end
  end

  # Override ActionText::Attachment to include pages in full_attributes
  ActionText::Attachment.class_eval do
    alias_method :original_full_attributes, :full_attributes rescue nil

    def self.sgids_with_pages
      @sgids_with_pages ||= {}
    end

    def full_attributes
      # Return cached result if available to avoid overwriting pages data
      return @full_attributes_with_pages if defined?(@full_attributes_with_pages)

      attrs = if respond_to?(:original_full_attributes)
        original_full_attributes
      else
        attachable.trix_attachment_attributes
      end

      sgid = node&.[]("sgid")
      data_pages = node&.[]("data-pages")

      # If the node has data-pages, include it and remember this SGID has pages
      if node.present? && data_pages.present?
        attrs = attrs.merge("pages" => data_pages)
        self.class.sgids_with_pages[sgid] = data_pages if sgid
      elsif sgid && self.class.sgids_with_pages.key?(sgid)
        # This SGID was already processed with pages data, use that
        attrs = attrs.merge("pages" => self.class.sgids_with_pages[sgid])
      elsif attrs.is_a?(Hash) && !attrs.key?("pages") && !attrs.key?(:pages)
        # Only add empty pages key if it doesn't exist
        attrs = attrs.merge("pages" => "")
      end

      @full_attributes_with_pages = attrs
      attrs
    end
  end
end
