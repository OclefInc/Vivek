class AddCounterCachesToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :assignments_count, :integer, default: 0, null: false
    add_column :students, :lessons_count, :integer, default: 0, null: false
  end
end
