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
  has_rich_text :description

  validates :name, presence: true

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
