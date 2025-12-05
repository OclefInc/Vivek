require "test_helper"

class DailyLessonNotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends email to subscribers when there are new lessons" do
    # Clear existing data to ensure clean state
    Lesson.destroy_all
    Subscription.destroy_all

    # Create an assignment
    assignment = assignments(:one)

    # Create a lesson for this assignment created within the last 24 hours
    lesson = Lesson.create!(name: "New Lesson", assignment: assignment, created_at: 1.hour.ago)

    # Create subscribers for this assignment
    subscriber1 = users(:one)
    subscriber2 = users(:two)

    Subscription.create!(assignment: assignment, user: subscriber1)
    Subscription.create!(assignment: assignment, user: subscriber2)

    # We expect 2 emails to be sent (enqueued and then performed)
    assert_difference -> { ActionMailer::Base.deliveries.size }, 2 do
      perform_enqueued_jobs do
        DailyLessonNotificationJob.perform_now
      end
    end
  end

  test "does not send email when there are no new lessons" do
    # Clear existing data
    Lesson.destroy_all
    Subscription.destroy_all

    # Create an assignment
    assignment = assignments(:one)

    # Create a lesson created more than 24 hours ago
    Lesson.create!(name: "Old Lesson", assignment: assignment, created_at: 25.hours.ago)

    # Create a subscriber
    subscriber = users(:one)
    Subscription.create!(assignment: assignment, user: subscriber)

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      perform_enqueued_jobs do
        DailyLessonNotificationJob.perform_now
      end
    end
  end

  test "does not send email when there are no subscribers" do
    # Clear existing data
    Lesson.destroy_all
    Subscription.destroy_all

    # Create an assignment
    assignment = assignments(:one)

    # Create a lesson created within the last 24 hours
    Lesson.create!(name: "New Lesson", assignment: assignment, created_at: 1.hour.ago)

    # Ensure no subscriptions for this assignment
    # (Already cleared above)

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      perform_enqueued_jobs do
        DailyLessonNotificationJob.perform_now
      end
    end
  end
end
