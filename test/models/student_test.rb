# == Schema Information
#
# Table name: students
#
#  id                 :bigint           not null, primary key
#  age_started_piano  :integer
#  assignments_count  :integer          default(0), not null
#  avatar_crop_height :integer
#  avatar_crop_width  :integer
#  avatar_crop_x      :integer
#  avatar_crop_y      :integer
#  lessons_count      :integer          default(0), not null
#  name               :string
#  year_of_birth      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
