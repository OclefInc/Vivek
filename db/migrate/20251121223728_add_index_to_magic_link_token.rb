class AddIndexToMagicLinkToken < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :magic_link_token, unique: true
  end
end
