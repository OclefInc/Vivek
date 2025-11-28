# == Schema Information
#
# Table name: teachers
#
#  id                 :bigint           not null, primary key
#  avatar_crop_height :integer
#  avatar_crop_width  :integer
#  avatar_crop_x      :integer
#  avatar_crop_y      :integer
#  city               :string
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
class Teacher < ApplicationRecord
  has_many :tutorials
  has_many :skill_categories, through: :tutorials
  has_many :lessons
  has_many :assignments, through: :lessons
  has_one_attached :profile_picture
  has_rich_text :bio
  belongs_to :user, optional: true
  validates_presence_of :name

  after_save :touch_assignments

  def projects
    assignments.uniq
  end

  def initials
    name.split.map { |part| part[0] }.join.upcase if name.present?
  end

  def display_avatar(size: 400)
    if profile_picture.attached?
      cropped_avatar(size: size)
    elsif user.present? && user.avatar.attached?
      user.cropped_avatar(size: size)
    elsif user.present? && user.picture_url.present?
      user.picture_url
    else
      nil
    end
  end

  def cropped_avatar(size: 400)
    return nil unless profile_picture.attached?

    if avatar_crop_x.present? && avatar_crop_y.present? && avatar_crop_width.present? && avatar_crop_height.present?
      # Use Vips operations for cropping
      profile_picture.variant(
        crop: [ avatar_crop_x, avatar_crop_y, avatar_crop_width, avatar_crop_height ],
        resize_to_fill: [ size, size ]
      )
    else
      profile_picture.variant(resize_to_fill: [ size, size ])
    end
  end

  def using_user_avatar?
    user.present? && (user.avatar.attached? || user.picture_url.present?)
  end

  private

    def touch_assignments
      tutorials.find_each(&:touch)
      lessons.find_each(&:touch)
      # Touch all assignments where this teacher taught a lesson to bust cache
      assignments.distinct.find_each(&:touch)
    end
end
