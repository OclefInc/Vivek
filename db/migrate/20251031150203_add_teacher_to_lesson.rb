class AddTeacherToLesson < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :teacher_id, :integer
  end
end
