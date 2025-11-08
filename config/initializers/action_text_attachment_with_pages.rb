# # Configuration: Define custom attachment attributes to preserve
# CUSTOM_ATTACHMENT_ATTRIBUTES = %w[
#   pages
# ].freeze

# # Override ActiveStorage::Blob to include custom attributes in Trix attachment JSON
# Rails.application.config.to_prepare do
#   ActiveStorage::Blob.class_eval do
#     # Add custom data when converting blob to Trix attachment attributes
#     alias_method :original_trix_attachment_attributes, :trix_attachment_attributes rescue nil

#     def trix_attachment_attributes
#       attrs = if respond_to?(:original_trix_attachment_attributes)
#         original_trix_attachment_attributes
#       else
#         {
#           sgid: attachable_sgid,
#           content_type: content_type,
#           filename: filename.to_s,
#           filesize: byte_size,
#           previewable: previewable?,
#           url: url
#         }
#       end

#       # Add custom attributes from stored data-* attributes
#       CUSTOM_ATTACHMENT_ATTRIBUTES.each do |attr_name|
#         begin
#           method_name = "data_#{attr_name}"
#           if respond_to?(method_name)
#             value = send(method_name)
#             attrs[attr_name.to_sym] = value if value.present?
#           end
#         rescue => e
#           Rails.logger.error "Error getting #{method_name} for blob #{id}: #{e.message}"
#           attrs[attr_name.to_sym] = "" unless attrs.key?(attr_name.to_sym)
#         end
#       end

#       # Ensure all custom attribute keys exist
#       CUSTOM_ATTACHMENT_ATTRIBUTES.each do |attr_name|
#         attrs[attr_name.to_sym] ||= ""
#       end

#       attrs
#     end
#   end

#   # Override ActionText::Attachment to include custom attributes in full_attributes
#   ActionText::Attachment.class_eval do
#     alias_method :original_full_attributes, :full_attributes rescue nil

#     def self.custom_attributes_by_sgid
#       @custom_attributes_by_sgid ||= {}
#     end

#     def full_attributes
#       # Return cached result if available to avoid overwriting custom data
#       return @full_attributes_with_custom if defined?(@full_attributes_with_custom)

#       attrs = if respond_to?(:original_full_attributes)
#         original_full_attributes
#       else
#         attachable.trix_attachment_attributes
#       end

#       sgid = node&.[]("sgid")

#       # Process each custom attribute
#       CUSTOM_ATTACHMENT_ATTRIBUTES.each do |attr_name|
#         data_attr = node&.[]("data-#{attr_name}")

#         # If the node has this data attribute, include it and remember it for this SGID
#         if node.present? && data_attr.present?
#           attrs = attrs.merge(attr_name => data_attr)
#           if sgid
#             self.class.custom_attributes_by_sgid[sgid] ||= {}
#             self.class.custom_attributes_by_sgid[sgid][attr_name] = data_attr
#           end
#         elsif sgid && self.class.custom_attributes_by_sgid.dig(sgid, attr_name)
#           # This SGID was already processed with this attribute, use that cached value
#           attrs = attrs.merge(attr_name => self.class.custom_attributes_by_sgid[sgid][attr_name])
#         elsif attrs.is_a?(Hash) && !attrs.key?(attr_name) && !attrs.key?(attr_name.to_sym)
#           # Only add empty key if it doesn't exist
#           attrs = attrs.merge(attr_name => "")
#         end
#       end

#       @full_attributes_with_custom = attrs
#       attrs
#     end
#   end
# end
