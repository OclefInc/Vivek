class AddStudentAgeToAssignment < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :student_age, :integer
  end
end
