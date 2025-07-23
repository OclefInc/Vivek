class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :student
      t.string :teacher
      t.string :composition

      t.timestamps
    end
  end
end
