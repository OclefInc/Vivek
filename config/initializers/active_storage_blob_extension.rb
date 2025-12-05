module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  def attachments
    @attachments ||= ActiveStorage::Attachment.where(blob_id: id)
  end

  def find_attachment_from_instance_variables(instance_variables)
    instance_variables.map { |var| attachment(var) }.compact.first
  end

  def attachment(record)
    attachments.find do |att|
      att.record == record || (att.record.respond_to?(:record) && att.record.record == record)
    end
  end
end

module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  def rich_text
    @rich_text ||= self.record
  end

  def model_record
    rich_text&.record
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::Blob.include ActiveStorageBlobExtension
  ActiveStorage::Attachment.include ActiveStorageAttachmentExtension
end
