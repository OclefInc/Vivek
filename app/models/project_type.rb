# == Schema Information
#
# Table name: project_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ProjectType < ApplicationRecord
  has_many :assignments
end
