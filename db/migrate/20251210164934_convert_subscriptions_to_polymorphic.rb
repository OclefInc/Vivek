class ConvertSubscriptionsToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Add polymorphic columns
    add_column :subscriptions, :subscribable_type, :string
    add_column :subscriptions, :subscribable_id, :bigint

    # Migrate existing data
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE subscriptions
          SET subscribable_type = 'Assignment', subscribable_id = assignment_id
          WHERE assignment_id IS NOT NULL
        SQL
      end
    end

    # Add index for polymorphic association
    add_index :subscriptions, [:subscribable_type, :subscribable_id]

    # Remove old foreign key and column
    remove_foreign_key :subscriptions, :assignments
    remove_column :subscriptions, :assignment_id
  end

  def down
    # Add back assignment_id column
    add_column :subscriptions, :assignment_id, :bigint

    # Migrate data back
    reversible do |dir|
      dir.down do
        execute <<-SQL
          UPDATE subscriptions
          SET assignment_id = subscribable_id
          WHERE subscribable_type = 'Assignment'
        SQL
      end
    end

    # Remove polymorphic columns and index
    remove_index :subscriptions, [:subscribable_type, :subscribable_id]
    remove_column :subscriptions, :subscribable_type
    remove_column :subscriptions, :subscribable_id

    # Add back foreign key
    add_foreign_key :subscriptions, :assignments
    add_index :subscriptions, :assignment_id
  end
end
