# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_crop_height     :integer
#  avatar_crop_width      :integer
#  avatar_crop_x          :integer
#  avatar_crop_y          :integer
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  magic_link_sent_at     :datetime
#  magic_link_token       :string
#  name                   :string
#  picture_url            :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_magic_link_token      (magic_link_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable, :confirmable, :lockable, :omniauthable,
         omniauth_providers: [ :google_oauth2, :apple, :facebook, :github ]

  has_one :teacher
  has_one :student
  has_one_attached :avatar
  has_many :likes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_assignments, through: :subscriptions, source: :assignment
  has_many :bookmarks, dependent: :destroy

  validates_presence_of :name
  # Make password optional for non-OAuth users (they use magic links)
  validates :password, presence: true, if: :password_required?

  after_save :touch_related_assignments

  # Override Devise's password_required? method
  def password_required?
    # Password required for OAuth users on creation, or when explicitly setting password
    oauth_user? && !persisted? || password.present? || password_confirmation.present?
  end

  def email_required?
    true
  end

  # OmniAuth callback method
  def self.from_omniauth(auth)
    # First try to find by provider/uid
    user = where(provider: auth.provider, uid: auth.uid).first

    # If not found, try to find by email
    unless user
      user = find_by(email: auth.info.email)
      if user
        # If found by email, update provider/uid to link the account
        user.provider = auth.provider
        user.uid = auth.uid
      else
        # If still not found, initialize new user
        user = new(provider: auth.provider, uid: auth.uid)
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name || "#{auth.info.first_name} #{auth.info.last_name}".strip
        user.skip_confirmation!
      end
    end

    # Always update picture_url on login to get latest/higher quality image
    user.picture_url = auth.info.image
    user.save!

    user
  end

  def initials
    name.split.map { |part| part[0] }.join.upcase if name.present?
  end

  def cropped_avatar(size: 400)
    return nil unless avatar.attached?

    if avatar_crop_x.present? && avatar_crop_y.present? && avatar_crop_width.present? && avatar_crop_height.present?
      # Use Vips operations for cropping
      avatar.variant(
        crop: [ avatar_crop_x, avatar_crop_y, avatar_crop_width, avatar_crop_height ],
        resize_to_fill: [ size, size ]
      )
    else
      avatar.variant(resize_to_fill: [ size, size ])
    end
  end

  def roles
    array = []
    array << "Employee" if is_employee?
    array << "Student" if is_student?
    array << "Teacher" if is_teacher?
    array
  end

  def is_employee?
    email.ends_with?("oclef.com")
  end
  def is_student?
    Student.where(user_id: self.id).any?
  end
  def is_teacher?
    Teacher.where(user_id: self.id).any?
  end

  def account_type
    @account_type ||= begin
    array = []

    array << "Employee" if is_employee?
    array << "Teacher" if is_teacher?
    array << "Student" if is_student?

    if array.empty?
      "Guest"
    else
      array.join(", ")
    end
  end
  end

  # Magic link authentication methods
  def generate_magic_link_token!
    self.magic_link_token = Devise.friendly_token(48)
    self.magic_link_sent_at = Time.current
    save(validate: false)
  end

  def magic_link_valid?
    magic_link_sent_at.present? && magic_link_sent_at > 15.minutes.ago
  end

  def send_magic_link
    generate_magic_link_token!
    MagicLinkMailer.login_link(self).deliver_now
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  private

    def touch_related_assignments
      # Touch student's assignments if user has a student profile
      if student.present?
        student.touch
        student.assignments.update_all(updated_at: Time.current)
      end

      # Touch teacher's assignments if user has a teacher profile
      if teacher.present?
        teacher.touch
        teacher.assignments.distinct.update_all(updated_at: Time.current)
      end
    end
end
