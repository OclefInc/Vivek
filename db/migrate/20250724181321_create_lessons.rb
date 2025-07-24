class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :name
      t.integer :assignment_id

      t.timestamps
    end
  end
end
