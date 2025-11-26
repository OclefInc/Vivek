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

  after_save :touch_assignments
  has_one_attached :profile_picture
  has_rich_text :bio
  belongs_to :user, optional: true

  validates_presence_of :profile_picture
  validates_presence_of :name, :year_of_birth
  validate :profile_picture_is_image_type

  def profile_picture_is_image_type
    unless profile_picture.present? && profile_picture.content_type.starts_with?("image/")
      errors.add(:profile_picture, "must be an image file")
    end
  end

  def initials
    name.split.map { |part| part[0] }.join.upcase if name.present?
  end

  def display_avatar(size: 400)
    # Use user's avatar if student belongs to a user and avatar is attached
    if user.present? && user.avatar.attached?
      user.cropped_avatar(size: size)
    elsif user.present? && user.picture_url.present?
      user.picture_url
    elsif profile_picture.attached?
      profile_picture.variant(resize_to_fill: [ size, size ])
    else
      nil
    end
  end

  def using_user_avatar?
    user.present? && (user.avatar.attached? || user.picture_url.present?)
  end

  private

    def touch_assignments
      assignments.find_each(&:touch)
    end
end
