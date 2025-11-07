class AttachmentsController < ApplicationController
  def update_metadata
    sgid = params[:sgid]
    blob = ActiveStorage::Blob.find_signed(sgid)

    if blob
      # Only save blob-level metadata (shared across all attachments)
      blob.metadata["copyrighted"] = params[:copyrighted]
      blob.metadata["purchase_url"] = params[:purchase_url] if params[:purchase_url].present?
      # Note: pages are NOT saved here - they're per-attachment via data-pages attribute
      blob.save!

      # Touch the associated objects to update their updated_at timestamp
      touch_associated_objects(blob)

      render json: { success: true }
    else
      render json: { error: "Blob not found" }, status: :not_found
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update_pages
    sgid = params[:sgid]
    pages = params[:pages]
    record_type = params[:record_type]
    record_id = params[:record_id]

    blob = ActiveStorage::Blob.find_signed(sgid)

    if blob && record_type && record_id
      # Find the specific Action Text rich text record for this record
      # The name is typically the field name (e.g., "description")
      rich_text = ActionText::RichText.find_by(
        record_type: record_type,
        record_id: record_id,
        name: "description" # Adjust if you have multiple rich text fields
      )

      if rich_text
        # Get the body as ActionText::Content
        content = rich_text.body

        # Parse the HTML content
        doc = Nokogiri::HTML.fragment(content.to_html)

        # Action Text stores attachments as <action-text-attachment> elements with an sgid attribute
        # The sgid contains the attachable SGID, which may have expired
        # We search by matching the URL (which contains the blob key) or by decoding the SGID

        attachment_element = doc.css("action-text-attachment").find do |el|
          el_sgid = el["sgid"]
          el_url = el["url"]

          # Try to match by URL containing the blob key
          if el_url&.include?(blob.key)
            true
          # Or try to decode the SGID
          elsif el_sgid
            begin
              # Use locate_signed which handles attachable SGIDs
              attachable = GlobalID::Locator.locate_signed(el_sgid, for: :attachable)
              attachable.is_a?(ActiveStorage::Blob) && attachable.id == blob.id
            rescue
              false
            end
          else
            false
          end
        end

        if attachment_element
          # Check if already wrapped in a div with data-pages
          parent = attachment_element.parent
          if parent.name == "div" && parent["data-attachment-pages"]
            # Already wrapped, just update the data-pages attribute
            parent["data-pages"] = pages
          else
            # Wrap the action-text-attachment in a div with data-pages attribute
            wrapper = Nokogiri::XML::Node.new("div", doc)
            wrapper["data-attachment-pages"] = "true"
            wrapper["data-pages"] = pages

            # Replace the attachment element with the wrapped version
            attachment_element.replace(wrapper)
            wrapper.add_child(attachment_element)
          end

          # Create new ActionText::Content from the modified HTML
          rich_text.update(body: doc.to_html)

          # Touch the parent record
          rich_text.record.touch if rich_text.record

          render json: { success: true }
        else
          Rails.logger.error "Attachment element not found. Content: #{content.to_html[0..500]}"
          render json: { error: "Attachment not found in content" }, status: :not_found
        end
      else
        render json: { error: "Rich text record not found" }, status: :not_found
      end
    else
      render json: { error: "Missing required parameters" }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def touch_associated_objects(blob)
    # Find all records that have this blob attached in their Action Text rich text fields
    ActionText::RichText.where("body LIKE ?", "%#{blob.key}%").find_each do |rich_text|
      # Touch the associated record (could be Lesson, Assignment, or any other model)
      rich_text.record.touch if rich_text.record
    end
  end
end
