class CommentMailerPreview<ActionMailer::Preview
  def notify_admin
    comment_id=Comment.first.id
    CommentMailer.notify_admin(comment_id)
  end
end
