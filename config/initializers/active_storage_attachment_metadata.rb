# Extend ActiveStorage::Attachment with metadata helpers
Rails.application.config.to_prepare do
  ActiveStorage::Attachment.class_eval do
    # Store metadata accessor
    store_accessor :metadata, :pages

    # Add more custom metadata fields here as needed:
    # store_accessor :metadata, :pages, :start_time, :end_time, :author
  end
end
