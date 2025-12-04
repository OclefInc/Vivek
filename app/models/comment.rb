# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  annotation_type  :string
#  unpublished_date :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin_id         :integer
#  annotation_id    :integer
#  user_id          :integer
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :annotation, polymorphic: true, touch: true
  has_rich_text :note
  has_many :likes, as: :likeable, dependent: :destroy
  after_create :email_notification

  def published_status
    if is_published?
      "published"
    else
      "unpublished"
    end
  end

  def toggle_publish(a_id)
    if is_published?
      self.unpublished_date = Time.now
      self.admin_id = a_id
      self.save
      CommentMailer.notify_user(self.id).deliver_later(wait: 60.minutes)
    else
      self.unpublished_date = nil
      self.admin_id = a_id
      self.save
    end
  end

  def is_published?
    self.unpublished_date.nil?
  end

  validate :content_validity

  private

    def content_validity
      text = note.to_plain_text.to_s.strip
      unless text.present?
        errors.add(:note, "cannot be blank")
      end

      # AI Content Validation
      # Skip if we are just publishing/unpublishing or if other validations failed
      if errors.blank? && !unpublished_date_changed? && !admin_id_changed?
        is_valid, reason = AiContentValidator.validate(text)
        unless is_valid
          errors.add(:base, reason)
        end
      end
    end

  private
    def email_notification
      CommentMailer.notify_contributors(self.id).deliver_later
      # CommentMailer.notify_admin(self.id).deliver_later
    end
end
