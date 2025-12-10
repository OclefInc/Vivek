class AddShowOnContributorsToTeachersAndStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :teachers, :show_on_contributors, :boolean, default: true, null: false
    add_column :students, :show_on_contributors, :boolean, default: true, null: false
  end
end
