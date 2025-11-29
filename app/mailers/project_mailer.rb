class ProjectMailer < ApplicationMailer
  def new_lesson_notification(user, lesson)
    @user = user
    @lesson = lesson
    @project = lesson.assignment
    mail(to: @user.email, subject: "New Lesson Added: #{@project.name}")
  end
end
