class CreateLessonsSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons_skills do |t|
      t.integer :lesson_id
      t.integer :skill_id

      t.timestamps
    end
  end
end
