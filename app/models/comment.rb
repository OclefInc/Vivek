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

  def published_status
    if is_published?
      "published"
    else 
      "unpublished"
    end
  end

  def toggle_publish(a_id)
    if is_published?
      self.unpublished_date=Time.now
      self.admin_id=a_id
      self.save
      CommentMailer.notify_user(self.id).deliver_later(wait:60.minutes)
    else
      self.unpublished_date=nil
      self.admin_id=a_id
      self.save
    end
  end

  def is_published?
    self.unpublished_date.nil?
  end

  private
  def email_admin
    CommentMailer.notify_admin(self.id).deliver_later
  end
end
