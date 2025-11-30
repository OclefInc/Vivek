# == Schema Information
#
# Table name: assignments
#
#  id              :bigint           not null, primary key
#  composition     :string
#  project_name    :string
#  student         :string
#  teacher         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  composition_id  :integer
#  project_type_id :bigint
#  student_id      :integer
#  teacher_id      :integer
#
# Indexes
#
#  index_assignments_on_project_type_id  (project_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_type_id => project_types.id)
#
require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
