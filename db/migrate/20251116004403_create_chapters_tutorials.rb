class CreateChaptersTutorials < ActiveRecord::Migration[8.0]
  def change
    create_table :chapters_tutorials do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :tutorial, null: false, foreign_key: true

      t.timestamps
    end
  end
end
