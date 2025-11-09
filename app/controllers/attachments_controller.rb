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

    blob = ActiveStorage::Blob.find_signed(sgid)

    if blob
      attachment = blob.attachment
      if attachment
        sql = <<-SQL
          UPDATE active_storage_attachments
          SET metadata = '{"pages":#{pages}}'
          WHERE id = #{attachment.id}
        SQL
        ActiveRecord::Base.connection.execute(sql)
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
