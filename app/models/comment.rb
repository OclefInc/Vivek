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
  after_create :email_admin
  def unpublish(a_id)
    self.unpublished_date=Time.now
    self.admin_id=a_id
    self.save
  end
  def is_published?
    self.unpublished_date.nil?
  end
  private
  def email_admin
    CommentMailer.notify_admin(self.id)
  end
end
