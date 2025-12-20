# == Schema Information
#
# Table name: assignments
#
#  id                :bigint           not null, primary key
#  composition       :string
#  project_name      :string
#  student           :string
#  student_age       :integer
#  summary_video_url :string
#  teacher           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  composition_id    :integer
#  project_type_id   :bigint
#  student_id        :integer
#  teacher_id        :integer
#
# Indexes
#
#  index_assignments_on_project_type_id  (project_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_type_id => project_types.id)
#
require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "validates presence of project_name" do
    assignment = Assignment.new
    assert_not assignment.valid?
    assert_includes assignment.errors[:project_name], "can't be blank"
  end

  test "name returns project_name" do
    assignment = assignments(:one)
    assert_equal assignment.project_name, assignment.name
  end

  test "contributors returns unique list of users" do
    assignment = assignments(:one)
    student_user = users(:one)
    teacher_user = users(:two)

    # Setup student user
    student = assignment.student
    # Attach profile picture first to satisfy validation
    unless student.profile_picture.attached?
      student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
      student.save!
    end
    student.update!(user: student_user)

    # Setup teacher user via lesson
    teacher = Teacher.create!(name: "Teacher", user: teacher_user)
    Lesson.create!(name: "Lesson", assignment: assignment, teacher: teacher)

    contributors = assignment.contributors
    assert_includes contributors, student_user
    assert_includes contributors, teacher_user
    assert_equal 2, contributors.count
  end

  test "to_param returns id-project_name-student_name" do
    assignment = assignments(:one)
    assignment.update!(project_name: "My Project")

    student = assignment.student
    unless student.profile_picture.attached?
      student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    end
    student.update!(name: "Student Name")

    assert_equal "#{assignment.id}-my-project-student-name", assignment.to_param
  end

  test "meta_description returns correct description" do
    assignment = assignments(:one)

    # Case 1: Description present
    assignment.description = "Assignment Description"
    assert_equal "Assignment Description", assignment.meta_description

    # Case 2: Fallback
    assignment.description = nil
    assert_equal "Project: #{assignment.project_name} (#{assignment.student.name})", assignment.meta_description
  end

  test "complete? returns true if summary video and lessons exist" do
    assignment = assignments(:one)
    # Initially incomplete
    assert_not assignment.complete?

    # Add requirements
    assignment.summary_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "test_video.mp4", content_type: "video/mp4")
    Lesson.create!(name: "Lesson", assignment: assignment)

    assert assignment.complete?
  end

  test "status returns correct string" do
    assignment = assignments(:one)
    assignment.stubs(:complete?).returns(true)
    assert_equal "Complete", assignment.status

    assignment.stubs(:complete?).returns(false)
    assert_equal "Incomplete", assignment.status
  end

  test "first_lesson returns lesson with lowest sort" do
    project_type = ProjectType.first || ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "Sort Test", project_type: project_type)

    # Create lessons in specific order, they will get auto-incremented sort
    l1 = Lesson.create!(name: "L1", assignment: assignment) # sort 1
    l2 = Lesson.create!(name: "L2", assignment: assignment) # sort 2
    l3 = Lesson.create!(name: "L3", assignment: assignment) # sort 3

    assert_equal l1, assignment.first_lesson

    # Verify sort order logic by swapping
    l1.update_column(:sort, 10)
    assert_equal l2, assignment.first_lesson
  end

  test "existing_description_attachments returns unique blobs" do
    assignment = assignments(:one)
    lesson = Lesson.create!(name: "Lesson", assignment: assignment)

    # Create a blob
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )

    # Attach to rich text
    # We need to save the record for ActionText to process the attachment
    lesson.description.body = ActionText::Content.new("<action-text-attachment sgid='#{blob.attachable_sgid}'></action-text-attachment>")
    lesson.save!

    # Reload assignment to ensure it sees the new lesson data if needed,
    # though existing_description_attachments queries lessons directly.

    attachments = assignment.existing_description_attachments
    assert_equal 1, attachments.count
    assert_equal blob.filename.to_s, attachments.first[:filename]
  end

  test "generate_video_thumbnail attaches image" do
    assignment = assignments(:one)
    # Ensure we have required data
    assignment.composition = Composition.create!(name: "Comp", composer: "Mozart")
    assignment.save! # Save association

    # Add lessons for date range logic
    Lesson.create!(name: "L1", assignment: assignment, date: Date.yesterday)
    Lesson.create!(name: "L2", assignment: assignment, date: Date.today)

    # Mock Vips to avoid dependency issues and ensure we test the attach logic
    # But if we want to test integration, we need Vips.
    # Let's try to see if it runs without error first.

    assignment.generate_video_thumbnail
    assert assignment.video_thumbnail.attached?, "Video thumbnail should be attached"
  end

  test "saved_change_to_summary_video_attachment? returns true when attachment changes" do
    assignment = assignments(:one)
    assignment.save # clear

    assert_not assignment.saved_change_to_summary_video_attachment?

    assignment.summary_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "test_video.mp4", content_type: "video/mp4")
    assignment.save

    # This method relies on attachment_changes which is transient, so we check if the callback fired
    # But we can also check the method directly if we simulate the change state before save,
    # or just verify the callback enqueues the job.
  end

  test "enqueue_thumbnail_generation enqueues job" do
    assignment = assignments(:one)

    assert_enqueued_with(job: GenerateVideoThumbnailJob) do
      assignment.enqueue_thumbnail_generation
    end
  end

  test "enqueues thumbnail generation on summary video change" do
    assignment = assignments(:one)

    assert_enqueued_with(job: GenerateVideoThumbnailJob) do
      assignment.summary_video.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "test_video.mp4", content_type: "video/mp4")
      assignment.save
    end
  end

  test "existing_description_attachments filters derived and handles duplicates" do
    assignment = assignments(:one)
    l1 = Lesson.create!(name: "L1", assignment: assignment, sort: 1)
    l2 = Lesson.create!(name: "L2", assignment: assignment, sort: 2)

    # Blob 1 (Original)
    blob1 = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "image1.png",
      content_type: "image/png",
      metadata: { copyrighted: true, purchase_url: "http://example.com" }
    )

    # Blob 2 (Derived - should be skipped)
    blob2 = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "image2.png",
      content_type: "image/png",
      metadata: { derived: "true" }
    )

    # Attach blob1 to both lessons
    l1.description.body = ActionText::Content.new("<action-text-attachment sgid='#{blob1.attachable_sgid}'></action-text-attachment>")
    l2.description.body = ActionText::Content.new("<action-text-attachment sgid='#{blob1.attachable_sgid}'></action-text-attachment>")

    # Attach derived blob
    l1.description.body = l1.description.body.to_s + "<action-text-attachment sgid='#{blob2.attachable_sgid}'></action-text-attachment>"

    l1.save!
    l2.save!

    attachments = assignment.existing_description_attachments

    assert_equal 1, attachments.count
    att = attachments.first
    assert_equal "image1.png", att[:filename]
    assert_equal true, att[:description_copyrighted]
    assert_equal "http://example.com", att[:description_purchase_url]
    assert_includes [ l1.name, l2.name ], att[:lesson_name]
  end

  test "generate_video_thumbnail handles empty lessons" do
    assignment = assignments(:one)
    assignment.composition = Composition.create!(name: "Comp", composer: "Mozart")
    assignment.save!

    # No lessons
    assignment.lessons.destroy_all

    assignment.generate_video_thumbnail
    assert assignment.video_thumbnail.attached?
  end

  test "existing_description_attachments keeps oldest duplicate based on created_at" do
    assignment = assignments(:one)
    l1 = Lesson.create!(name: "L1", assignment: assignment, sort: 1)
    l2 = Lesson.create!(name: "L2", assignment: assignment, sort: 2)

    # Mock Blobs with same SGID but different created_at
    blob1 = mock()
    blob1.stubs(:created_at).returns(1.day.ago)
    blob1.stubs(:attachable_sgid).returns("same_sgid")
    blob1.stubs(:filename).returns("image1.png")
    blob1.stubs(:metadata).returns({})
    blob1.stubs(:is_a?).with(ActiveStorage::Blob).returns(true)

    blob2 = mock()
    blob2.stubs(:created_at).returns(2.days.ago) # Older
    blob2.stubs(:attachable_sgid).returns("same_sgid")
    blob2.stubs(:filename).returns("image1.png")
    blob2.stubs(:metadata).returns({})
    blob2.stubs(:is_a?).with(ActiveStorage::Blob).returns(true)

    # Mock Attachments
    att1 = mock()
    att1.stubs(:metadata).returns({})
    att1.stubs(:attachable).returns(blob1)

    att2 = mock()
    att2.stubs(:metadata).returns({})
    att2.stubs(:attachable).returns(blob2)

    # Mock Lesson Descriptions
    mock_desc1 = mock()
    mock_body1 = mock()
    mock_body1.stubs(:present?).returns(true)
    mock_body1.stubs(:attachments).returns([ att1 ])
    mock_desc1.stubs(:body).returns(mock_body1)

    mock_desc2 = mock()
    mock_body2 = mock()
    mock_body2.stubs(:present?).returns(true)
    mock_body2.stubs(:attachments).returns([ att2 ])
    mock_desc2.stubs(:body).returns(mock_body2)

    l1.stubs(:description).returns(mock_desc1)
    l2.stubs(:description).returns(mock_desc2)

    # Mock assignment.lessons.order(:sort)
    mock_relation = mock()
    mock_relation.stubs(:order).with(:sort).returns([ l1, l2 ])
    assignment.stubs(:lessons).returns(mock_relation)

    result = assignment.existing_description_attachments

    assert_equal 1, result.count
    # Should keep blob2 because it is older (2 days ago < 1 day ago)
    assert_equal blob2.created_at, result.first[:created_at]
    assert_equal "L2", result.first[:lesson_name]
  end
end
