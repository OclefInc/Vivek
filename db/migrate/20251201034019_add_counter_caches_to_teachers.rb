class AddCounterCachesToTeachers < ActiveRecord::Migration[8.0]
  def change
    add_column :teachers, :tutorials_count, :integer, default: 0, null: false
    add_column :teachers, :assignments_count, :integer, default: 0, null: false
  end
end
