# == Schema Information
#
# Table name: assignments
#
#  id          :bigint           not null, primary key
#  composition :string
#  student     :string
#  teacher     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
