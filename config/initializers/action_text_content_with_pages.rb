# # Monkey-patch ActionText::Attachment to preserve custom data attributes from Trix JSON
# # when converting from editor format to storage format

# module ActionText
#   class Attachment
#     class << self
#       # Store the original method before we override it
#       alias_method :original_fragment_by_canonicalizing_attachments, :fragment_by_canonicalizing_attachments unless method_defined?(:original_fragment_by_canonicalizing_attachments)

#       # Override to preserve custom data attributes
#       def fragment_by_canonicalizing_attachments(content)
#         # Extract custom data attributes from any figure elements with Trix attachments before they're converted
#         temp_fragment = Nokogiri::HTML.fragment(content)
#         custom_attributes_by_sgid = {}

#         temp_fragment.css("figure[data-trix-attachment]").each do |figure|
#           begin
#             trix_json = figure["data-trix-attachment"]
#             next unless trix_json

#             attachment_data = JSON.parse(trix_json)
#             sgid = attachment_data["sgid"]
#             next unless sgid

#             # Extract any custom attributes (not the standard Action Text ones)
#             standard_attrs = %w[contentType filename filesize height width previewable sgid url content]
#             custom_attrs = attachment_data.except(*standard_attrs)

#             if custom_attrs.any?
#               custom_attributes_by_sgid[sgid] = custom_attrs
#             end
#           rescue JSON::ParserError => e
#             Rails.logger.error "Error parsing Trix attachment JSON: #{e.message}"
#           end
#         end

#         # Call the original method to do the conversion
#         result_fragment = original_fragment_by_canonicalizing_attachments(content)

#         # Now inject the custom attributes into the action-text-attachment elements
#         if custom_attributes_by_sgid.any?
#           # ActionText::Fragment wraps a Nokogiri fragment, access it via .source
#           result_fragment.source.css("action-text-attachment").each do |attachment|
#             sgid = attachment["sgid"]
#             if sgid && custom_attributes_by_sgid[sgid].present?
#               custom_attributes_by_sgid[sgid].each do |key, value|
#                 # Convert to data-* attribute format (e.g., "pages" -> "data-pages")
#                 attribute_name = key.start_with?("data-") ? key : "data-#{key}"
#                 attachment[attribute_name] = value.to_s
#               end
#             end
#           end
#         end

#         result_fragment
#       end
#     end
#   end
# end
