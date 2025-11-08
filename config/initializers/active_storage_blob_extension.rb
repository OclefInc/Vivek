module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  def attachment
    @attachment ||= ActiveStorage::Attachment.find_by(blob_id: id)
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::Blob.include ActiveStorageBlobExtension
end
