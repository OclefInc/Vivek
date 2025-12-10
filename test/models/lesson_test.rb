# == Schema Information
#
# Table name: lessons
#
#  id                       :bigint           not null, primary key
#  date                     :date
#  description_copyrighted  :boolean
#  description_purchase_url :string
#  name                     :string
#  sort                     :integer          default(1000)
#  video_end_time           :integer
#  video_start_time         :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assignment_id            :integer
#  teacher_id               :integer
#
require "test_helper"

class LessonTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "validates presence of name" do
    lesson = Lesson.new
    assert_not lesson.valid?
    assert_includes lesson.errors[:name], "can't be blank"
  end

  test "assigns default name from date if blank and video attached" do
    lesson = Lesson.new(date: Date.today)
    # Mock video attachment
    lesson.lesson_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "test_video.mp4", content_type: "video/mp4")

    lesson.send(:assign_default_name)
    assert_equal Date.today.to_s, lesson.name
  end

  test "assigns sort position" do
    project_type = ProjectType.first || ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "Sort Test", project_type: project_type)

    lesson1 = Lesson.create!(name: "Lesson 1", assignment: assignment, sort: 1)

    lesson2 = Lesson.new(name: "Lesson 2", assignment: assignment)
    lesson2.save!

    assert_equal 2, lesson2.sort
  end

  test "complete? returns true if all conditions met" do
    lesson = lessons(:one)
    # Incomplete initially
    assert_not lesson.complete?

    # Add requirements
    lesson.teacher = teachers(:one)
    lesson.chapters.create!(name: "Chapter 1", start_time: 0, lesson: lesson)
    lesson.lesson_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "test_video.mp4", content_type: "video/mp4")
    lesson.description = "Description"

    assert lesson.complete?
  end

  test "status returns correct string" do
    lesson = lessons(:one)
    lesson.stubs(:complete?).returns(true)
    assert_equal "Complete", lesson.status

    lesson.stubs(:complete?).returns(false)
    assert_equal "Incomplete", lesson.status
  end

  test "next and previous lesson navigation" do
    project_type = ProjectType.first || ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "Nav Test", project_type: project_type)
    lesson1 = Lesson.create!(name: "1", assignment: assignment, sort: 1)
    lesson2 = Lesson.create!(name: "2", assignment: assignment, sort: 2)
    lesson3 = Lesson.create!(name: "3", assignment: assignment, sort: 3)

    assert_equal lesson2, lesson1.next_lesson
    assert_equal lesson3, lesson2.next_lesson
    assert_nil lesson3.next_lesson

    assert_equal lesson2, lesson3.previous_lesson
    assert_equal lesson1, lesson2.previous_lesson
    assert_nil lesson1.previous_lesson

    # Alias check
    assert_equal lesson2, lesson1.next
    assert_equal lesson1, lesson2.previous
  end

  test "meta_description returns correct description" do
    lesson = lessons(:one)

    # Case 1: Lesson description
    lesson.description = "Lesson Description"
    assert_equal "Lesson Description", lesson.meta_description

    # Case 2: Assignment description
    lesson.description = nil
    lesson.assignment.description = "Assignment Description"
    assert_equal "Assignment Description", lesson.meta_description

    # Case 3: Fallback
    lesson.assignment.description = nil
    assert_equal "Lesson #{lesson.name}", lesson.meta_description
  end

  test "assigns default date" do
    lesson = Lesson.new(name: "Test")
    lesson.send(:assign_default_date)
    assert_equal Date.today, lesson.date
  end

  test "assigns default teacher from assignment" do
    assignment = assignments(:one)
    # Ensure assignment has a teacher
    teacher = teachers(:one)
    assignment.update!(teacher: teacher)

    lesson = Lesson.new(name: "Test", assignment: assignment)
    lesson.send(:assign_default_teacher)

    assert_equal teacher.id, lesson.teacher_id
  end

  test "to_param returns id-name" do
    lesson = lessons(:one)
    lesson.update!(name: "My Lesson")
    assert_equal "#{lesson.id}-my-lesson", lesson.to_param
  end

  test "project returns assignment" do
    lesson = lessons(:one)
    assert_equal lesson.assignment, lesson.project
  end

  test "update_all_chapter_stop_times updates stop times" do
    project_type = ProjectType.first || ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "Chapter Test", project_type: project_type)
    lesson = Lesson.create!(name: "Chapter Lesson", assignment: assignment)

    c1 = lesson.chapters.create!(name: "C1", start_time: 0)
    c2 = lesson.chapters.create!(name: "C2", start_time: 10)
    c3 = lesson.chapters.create!(name: "C3", start_time: 20)

    lesson.update_all_chapter_stop_times

    assert_equal 10, c1.reload.stop_time
    assert_equal 20, c2.reload.stop_time
    assert_nil c3.reload.stop_time
  end

  test "lesson_video_is_video_type validates content type" do
    lesson = Lesson.new

    # Valid video
    lesson.lesson_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "test_video.mp4", content_type: "video/mp4")
    lesson.lesson_video_is_video_type
    assert_empty lesson.errors[:lesson_video]

    # Invalid type
    lesson.lesson_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    lesson.lesson_video_is_video_type
    assert_includes lesson.errors[:lesson_video], "must be a video file"
  end

  test "notify_subscribers sends emails" do
    lesson = lessons(:one)
    user = users(:two) # Use a different user
    # Subscribe user to assignment
    Subscription.create!(user: user, subscribable: lesson.assignment)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      lesson.notify_subscribers
    end
  end

  test "regenerate_assignment_thumbnail enqueues job" do
    lesson = lessons(:one)

    assert_enqueued_with(job: GenerateVideoThumbnailJob) do
      lesson.regenerate_assignment_thumbnail
    end
  end

  test "enqueue_thumbnail_generation enqueues job" do
    lesson = lessons(:one)

    assert_enqueued_with(job: GenerateLessonThumbnailJob) do
      lesson.enqueue_thumbnail_generation
    end
  end

  test "update_teacher_assignments_count updates counts" do
    teacher = Teacher.create!(name: "Count Teacher")
    project_type = ProjectType.first || ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "Count Test", project_type: project_type)
    lesson = Lesson.new(name: "Count Test", assignment: assignment, teacher: teacher)

    # Create
    # Note: If this fails with 2, check if Assignment creation also increments something or if Lesson creation triggers double update
    assert_difference "teacher.reload.assignments_count", 1 do
      lesson.save!
    end

    # Update teacher
    teacher2 = Teacher.create!(name: "Count Teacher 2")
    assert_difference "teacher.reload.assignments_count", -1 do
      assert_difference "teacher2.reload.assignments_count", 1 do
        lesson.update!(teacher: teacher2)
      end
    end

    # Destroy
    assert_difference "teacher2.reload.assignments_count", -1 do
      lesson.destroy
    end
  end

  test "update_student_lessons_count updates counts" do
    user = User.create!(email: "count_student@example.com", password: "password", name: "Count Student User")
    student = Student.new(name: "Count Student", user: user)
    # Attach profile picture to satisfy validation
    student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    student.save!

    project_type = ProjectType.first || ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: student, project_name: "Count Test", project_type: project_type)

    lesson = Lesson.new(name: "Count Test", assignment: assignment)

    # Create
    assert_difference "student.reload.lessons_count", 1 do
      lesson.save!
    end

    # Update assignment
    assignment2 = Assignment.create!(student: student, project_name: "Count Test 2", project_type: project_type)
    # Moving assignment shouldn't change total count for student, but let's verify logic runs
    lesson.update!(assignment: assignment2)
    assert_equal 1, student.reload.lessons_count

    # Destroy
    assert_difference "student.reload.lessons_count", -1 do
      lesson.destroy
    end
  end

  test "generate_video_thumbnail attaches image" do
    lesson = lessons(:one)
    # Ensure we have required data for the method
    lesson.assignment.project_type = ProjectType.first || ProjectType.create!(name: "Type")

    assert_difference "ActiveStorage::Attachment.count", 1 do
      lesson.generate_video_thumbnail
    end

    assert lesson.video_thumbnail.attached?
  end

  test "saved_change_to_thumbnail_attributes? returns true for relevant changes" do
    lesson = lessons(:one)
    lesson.save # clear changes

    lesson.name = "New Name"
    lesson.save
    assert lesson.saved_change_to_thumbnail_attributes?

    lesson.save # clear
    lesson.teacher_id = teachers(:two).id
    lesson.save
    assert lesson.saved_change_to_thumbnail_attributes?

    lesson.save # clear
    lesson.date = Date.yesterday
    lesson.save
    assert lesson.saved_change_to_thumbnail_attributes?
  end
end
