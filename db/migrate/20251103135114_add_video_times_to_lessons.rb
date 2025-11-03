class AddVideoTimesToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :video_start_time, :integer
    add_column :lessons, :video_end_time, :integer
  end
end
