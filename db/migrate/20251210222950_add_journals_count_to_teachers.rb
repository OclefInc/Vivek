class AddJournalsCountToTeachers < ActiveRecord::Migration[8.0]
  def change
    add_column :teachers, :journals_count, :integer, default: 0, null: false

    # Initialize counter cache for existing records
    reversible do |dir|
      dir.up do
        Teacher.find_each do |teacher|
          if teacher.user.present?
            journals_count = teacher.user.journals.count
            teacher.update_column(:journals_count, journals_count)
          end
        end
      end
    end
  end
end
