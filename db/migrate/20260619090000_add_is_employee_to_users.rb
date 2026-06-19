class AddIsEmployeeToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :is_employee, :boolean, default: false, null: false

    # Preserve current behavior for existing users by backfilling company-domain emails.
    execute <<~SQL
      UPDATE users
      SET is_employee = TRUE
      WHERE email ILIKE '%@oclef.com'
    SQL
  end

  def down
    remove_column :users, :is_employee
  end
end
