# == Schema Information
#
# Table name: teachers
#
#  id         :bigint           not null, primary key
#  city       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Teacher < ApplicationRecord
    validates_presence_of :name, :city
    has_many :assignments
    has_one_attached :profile_picture
end
