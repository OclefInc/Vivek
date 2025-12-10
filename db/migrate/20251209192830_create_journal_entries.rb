class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.references :journal, null: false, foreign_key: true
      t.date :date
      t.string :name
      t.integer :sort, default: 1000
      t.integer :video_start_time
      t.integer :video_end_time
      t.timestamps
    end
  end
end
