class AddSortToTutorial < ActiveRecord::Migration[8.0]
  def change
    add_column :tutorials, :sort, :integer
  end
end
