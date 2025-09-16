class CommentMailer < ApplicationMailer
  def notify_admin(comment_id)
    @comment=Comment.find(comment_id)
    admin_email="matthew@oclef.com"
    mail(to:admin_email, subject:"New Comment")
  end
end
