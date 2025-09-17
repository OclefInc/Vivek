class CommentMailer < ApplicationMailer

  def notify_admin(comment_id)
    @comment=Comment.find(comment_id)
    admin_email="matthew@oclef.com"
    mail(to:admin_email, subject:"New Comment")
  end

  def notify_user(comment_id)
    @comment=Comment.find(comment_id)
    user_email=@comment.user.email
    unless @comment.is_published?
      mail(to:user_email, subject:"Your comment has been unpublished")
    end
  end
end
