class AddCompositrionToAssignment < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :composition_id, :integer
  end
end
