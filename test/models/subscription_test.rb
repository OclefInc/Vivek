# == Schema Information
#
# Table name: subscriptions
#
#  id                :bigint           not null, primary key
#  subscribable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  subscribable_id   :bigint
#  user_id           :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_subscribable_type_and_subscribable_id  (subscribable_type,subscribable_id)
#  index_subscriptions_on_user_id                                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
