class DailyLessonNotificationJob < ApplicationJob
  queue_as :default

  def perform
    # Find lessons created in the last 24 hours
    lessons = Lesson.where(created_at: 24.hours.ago..Time.current)

    lessons.each do |lesson|
      project = lesson.assignment
      next unless project

      # Find subscribers
      project.subscriptions.includes(:user).each do |subscription|
        user = subscription.user
        ProjectMailer.new_lesson_notification(user, lesson).deliver_later
      end
    end
  end
end
