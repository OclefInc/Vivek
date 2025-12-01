class ResetAllCounters < ActiveRecord::Migration[8.0]
  def up
    Teacher.reset_all_counters
    Student.reset_all_counters
  end

  def down
  end
end
