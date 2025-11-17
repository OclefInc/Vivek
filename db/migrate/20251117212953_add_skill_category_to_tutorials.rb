class AddSkillCategoryToTutorials < ActiveRecord::Migration[8.0]
  def change
    add_reference :tutorials, :skill_category, null: true, foreign_key: true
  end
end
