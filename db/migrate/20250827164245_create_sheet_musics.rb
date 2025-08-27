class CreateSheetMusics < ActiveRecord::Migration[8.0]
  def change
    create_table :sheet_musics do |t|
      t.integer :composition_id

      t.timestamps
    end
  end
end
