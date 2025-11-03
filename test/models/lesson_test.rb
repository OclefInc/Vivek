# == Schema Information
#
# Table name: lessons
#
#  id            :bigint           not null, primary key
#  date          :date
#  name          :string
#  sort          :integer          default(1000)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :integer
#  teacher_id    :integer
#
require "test_helper"

class LessonTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
