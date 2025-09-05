class AddNewFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime
  end
end
## Lockable
# t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
# t.string   :unlock_token # Only if unlock strategy is :email or :both
# t.datetime :locked_at
