class CreateChapters < ActiveRecord::Migration[8.0]
  def change
    create_table :chapters do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :name
      t.integer :start_time

      t.timestamps
    end

    add_index :chapters, [ :lesson_id, :start_time ]
  end
end
