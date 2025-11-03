class AddDateToLesson < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :date, :date
  end
end
