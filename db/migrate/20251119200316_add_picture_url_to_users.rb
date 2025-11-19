class AddPictureUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :picture_url, :string
  end
end
