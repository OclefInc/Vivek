# == Schema Information
#
# Table name: bookmarks
#
#  id                :bigint           not null, primary key
#  bookmarkable_type :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  bookmarkable_id   :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_bookmarks_on_bookmarkable  (bookmarkable_type,bookmarkable_id)
#  index_bookmarks_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
