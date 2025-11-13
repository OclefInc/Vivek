class CreateTutorials < ActiveRecord::Migration[8.0]
  def change
    create_table :tutorials do |t|
      t.string :name
      t.references :teacher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
