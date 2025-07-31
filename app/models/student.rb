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
class Student < ApplicationRecord
    validates_presence_of :name, :year_of_birth
    has_many :assignments
    has_one_attached :profile_picture
end
