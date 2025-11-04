class AddCopyrightFieldsToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :description_copyrighted, :boolean
    add_column :lessons, :description_purchase_url, :string
  end
end
