class AddSortToChaptersTutorials < ActiveRecord::Migration[8.0]
  def change
    add_column :chapters_tutorials, :sort, :integer
  end
end
