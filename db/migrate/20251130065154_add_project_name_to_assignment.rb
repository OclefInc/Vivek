class AddProjectNameToAssignment < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :project_name, :string
  end
end
