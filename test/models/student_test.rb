# == Schema Information
#
# Table name: students
#
#  id            :bigint           not null, primary key
#  name          :string
#  year_of_birth :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
