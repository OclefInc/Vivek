class AddMetadataToActiveStorageAttachments < ActiveRecord::Migration[8.0]
  def change
    add_column :active_storage_attachments, :metadata, :jsonb, default: {}, null: false
    add_index :active_storage_attachments, :metadata, using: :gin
  end
end
