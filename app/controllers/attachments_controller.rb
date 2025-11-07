class AttachmentsController < ApplicationController
  def update_metadata
    sgid = params[:sgid]
    blob = ActiveStorage::Blob.find_signed(sgid)

    if blob
      blob.metadata["copyrighted"] = params[:copyrighted]
      blob.metadata["purchase_url"] = params[:purchase_url] if params[:purchase_url].present?
      blob.save!

      render json: { success: true }
    else
      render json: { error: "Blob not found" }, status: :not_found
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
