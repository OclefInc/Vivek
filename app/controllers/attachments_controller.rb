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
    record = record_type.constantize.find_by(id: record_id) if record_type.present? && record_id.present?

    blob = ActiveStorage::Blob.find_signed(sgid)

    if blob && record
      attachment = blob.attachment(record)
      if attachment
        attachment.pages = pages
        attachment.save!
      end

      render json: { success: true }
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
