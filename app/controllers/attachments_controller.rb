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

        # Find the div with data-controller="attachment-pages" and data-blob-sgid matching this blob
        attachment_div = doc.at_css("div[data-controller='attachment-pages'][data-blob-sgid='#{sgid}']")

        if attachment_div
          # Update the data-pages attribute
          attachment_div["data-pages"] = pages

          # Create new ActionText::Content from the modified HTML
          rich_text.update(body: doc.to_html)

          # Touch the parent record
          rich_text.record.touch if rich_text.record

          render json: { success: true }
        else
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
