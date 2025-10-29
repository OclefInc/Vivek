# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable

  validates_presence_of :name

  def roles
    array=[]
    array<<"Employee" if is_employee?
    array<<"Student" if is_student?
    array<<"Teacher" if is_teacher?
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
end
