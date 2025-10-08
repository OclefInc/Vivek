# == Schema Information
#
# Table name: teachers
#
#  id         :bigint           not null, primary key
#  city       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
class Teacher < ApplicationRecord
    has_many :assignments
    has_one_attached :profile_picture
    has_rich_text :bio
    belongs_to :user, optional: true
    validates_presence_of     :name, :city
end
