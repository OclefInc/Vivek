# == Schema Information
#
# Table name: comments
#
#  id              :bigint           not null, primary key
#  annotation_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  annotation_id   :integer
#  user_id         :integer
#
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
