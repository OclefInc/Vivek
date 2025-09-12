# == Schema Information
#
# Table name: comments
#
#  id              :bigint           not null, primary key
#  annotation_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  annotation_id   :integer
#  user_id         :integer
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :annotation, polymorphic: true, touch: true
  has_rich_text :note
end
