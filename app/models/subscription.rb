# == Schema Information
#
# Table name: subscriptions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_assignment_id  (assignment_id)
#  index_subscriptions_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignment_id => assignments.id)
#  fk_rails_...  (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :assignment
  validates :user_id, uniqueness: { scope: :assignment_id }
end
