class CreateSkillCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :skill_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
