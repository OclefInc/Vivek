# Monkey-patch ActionText::Attachment to preserve pages attribute from Trix JSON
# when converting from editor format to storage format

module ActionText
  class Attachment
    class << self
      # Store the original method before we override it
      alias_method :original_fragment_by_canonicalizing_attachments, :fragment_by_canonicalizing_attachments unless method_defined?(:original_fragment_by_canonicalizing_attachments)

      # Override to preserve pages data
      def fragment_by_canonicalizing_attachments(content)
        # Extract pages data from any figure elements with Trix attachments before they're converted
        temp_fragment = Nokogiri::HTML.fragment(content)
        pages_by_sgid = {}

        temp_fragment.css("figure[data-trix-attachment]").each do |figure|
          begin
            trix_json = figure["data-trix-attachment"]
            next unless trix_json

            attachment_data = JSON.parse(trix_json)
            if attachment_data["pages"].present? && attachment_data["sgid"].present?
              pages_by_sgid[attachment_data["sgid"]] = attachment_data["pages"]
            end
          rescue JSON::ParserError => e
            Rails.logger.error "Error parsing Trix attachment JSON: #{e.message}"
          end
        end

        # Call the original method to do the conversion
        result_fragment = original_fragment_by_canonicalizing_attachments(content)

        # Now inject the pages data into the action-text-attachment elements
        if pages_by_sgid.any?
          # ActionText::Fragment wraps a Nokogiri fragment, access it via .source
          result_fragment.source.css("action-text-attachment").each do |attachment|
            sgid = attachment["sgid"]
            if sgid && pages_by_sgid[sgid].present?
              attachment["data-pages"] = pages_by_sgid[sgid]
            end
          end
        end

        result_fragment
      end
    end
  end
end
