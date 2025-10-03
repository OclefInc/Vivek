# == Schema Information
#
# Table name: students
#
#  id            :bigint           not null, primary key
#  name          :string
#  year_of_birth :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#
class Student < ApplicationRecord
    
    has_many :assignments
    has_one_attached :profile_picture
    has_rich_text :bio
    belongs_to :user, optional: true

    validate :profile_picture_is_image_type
    validates_presence_of :profile_picture
    validates_presence_of :name, :year_of_birth

    def profile_picture_is_image_type
        unless profile_picture.content_type.starts_with?("image/")
          errors.add(:profile_picture, "must be an image file")
        end
    end
end
