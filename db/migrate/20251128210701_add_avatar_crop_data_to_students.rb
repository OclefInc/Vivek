class AddAvatarCropDataToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :avatar_crop_x, :integer
    add_column :students, :avatar_crop_y, :integer
    add_column :students, :avatar_crop_width, :integer
    add_column :students, :avatar_crop_height, :integer
  end
end
