# == Schema Information
#
# Table name: sheet_musics
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  composition_id :integer
#
class SheetMusic < ApplicationRecord
  belongs_to :composition

  has_rich_text :info
  has_one_attached :pdf_file
  has_many :comments, as: :annotation
  
  validates_presence_of :pdf_file
    validate :pdf_file_is_pdf_type

    def pdf_file_is_pdf_type
      if pdf_file.attached?
        unless pdf_file.content_type.starts_with?("application/pdf")
          errors.add(:pdf_file, "must be a PDF file")
        end
      end
    end

    def pdf_file_path
      ActiveStorage::Blob.service.path_for(pdf_file.key)
    end
end
