class AddStudentIdTeacherIdToAssignment < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :student_id, :integer
    add_column :assignments, :teacher_id, :integer
  end
end
