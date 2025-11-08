module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  # Returns the model record this blob is attached to, if any.
  def model_record
    rich_text&.record
  end

  def attachment
    @attachment ||= ActiveStorage::Attachment.find_by(blob_id: id)
  end

  def rich_text
    @rich_text ||= attachment&.record
  end

  def doc
    @doc ||= Nokogiri::HTML.fragment(rich_text.body.to_html)
  end

  def data_pages
    attachment_element.attributes["data-pages"]&.value
  end

  def attachment_element
    # Action Text stores attachments as <action-text-attachment> elements with an sgid attribute
    # The sgid contains the attachable SGID, which may have expired
    # We search by matching the URL (which contains the blob key) or by decoding the SGID

    doc.css("action-text-attachment").find do |el|
      el_sgid = el["sgid"]
      el_url = el["url"]

      # Try to match by URL containing the blob key
      if el_url&.include?(key)
        true
      # Or try to decode the SGID
      elsif el_sgid
        begin
          # Use locate_signed which handles attachable SGIDs
          attachable = GlobalID::Locator.locate_signed(el_sgid, for: :attachable)
          attachable.is_a?(ActiveStorage::Blob) && attachable.id == id
        rescue
          false
        end
      else
        false
      end
    end
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::Blob.include ActiveStorageBlobExtension
end
