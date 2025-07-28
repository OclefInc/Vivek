class CreateCompositions < ActiveRecord::Migration[8.0]
  def change
    create_table :compositions do |t|
      t.string :name
      t.string :composer

      t.timestamps
    end
  end
end
