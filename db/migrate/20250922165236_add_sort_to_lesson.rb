class AddSortToLesson < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :sort, :integer, default: 1000
  end
end
