class AddAgeStartedPianoToStudent < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :age_started_piano, :integer
  end
end
