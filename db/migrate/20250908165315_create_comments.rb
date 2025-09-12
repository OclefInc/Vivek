class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :annotation_id
      t.string :annotation_type

      t.timestamps
    end
  end
end
