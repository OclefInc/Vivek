# == Schema Information
#
# Table name: teachers
#
#  id                 :bigint           not null, primary key
#  assignments_count  :integer          default(0), not null
#  avatar_crop_height :integer
#  avatar_crop_width  :integer
#  avatar_crop_x      :integer
#  avatar_crop_y      :integer
#  city               :string
#  name               :string
#  tutorials_count    :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
require "test_helper"

class TeacherTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
