# == Schema Information
#
# Table name: teachers
#
#  id                   :bigint           not null, primary key
#  assignments_count    :integer          default(0), not null
#  avatar_crop_height   :integer
#  avatar_crop_width    :integer
#  avatar_crop_x        :integer
#  avatar_crop_y        :integer
#  city                 :string
#  journals_count       :integer          default(0), not null
#  name                 :string
#  show_on_contributors :boolean          default(TRUE), not null
#  tutorials_count      :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#
require "test_helper"

class TeacherTest < ActiveSupport::TestCase
  setup do
    @teacher = teachers(:one)
  end

  test "validates presence of name" do
    @teacher.name = nil
    assert_not @teacher.valid?
    assert_includes @teacher.errors[:name], "can't be blank"
  end

  test "to_param returns id-name-parameterized" do
    @teacher.update!(name: "Jane Doe")
    assert_equal "#{@teacher.id}-jane-doe", @teacher.to_param
  end

  test "projects returns unique assignments" do
    @teacher.assignments.destroy_all # Clear existing

    project_type = ProjectType.create!(name: "Type")

    # Create assignments and lessons
    assignment1 = Assignment.create!(student: students(:one), project_name: "P1", project_type: project_type)
    assignment2 = Assignment.create!(student: students(:one), project_name: "P2", project_type: project_type)

    Lesson.create!(name: "L1", assignment: assignment1, teacher: @teacher)
    Lesson.create!(name: "L2", assignment: assignment1, teacher: @teacher) # Same assignment
    Lesson.create!(name: "L3", assignment: assignment2, teacher: @teacher)

    # Reload teacher to pick up new associations
    @teacher.reload

    assert_equal 2, @teacher.projects.count
    assert_includes @teacher.projects, assignment1
    assert_includes @teacher.projects, assignment2
  end

  test "initials returns initials" do
    @teacher.update!(name: "Jane Doe")
    assert_equal "JD", @teacher.initials

    @teacher.update!(name: "Single")
    assert_equal "S", @teacher.initials
  end

  test "display_avatar returns profile picture variant if attached" do
    @teacher.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")

    assert_not_nil @teacher.display_avatar
    assert @teacher.display_avatar.is_a?(ActiveStorage::Variant) || @teacher.display_avatar.is_a?(ActiveStorage::VariantWithRecord)
  end

  test "display_avatar falls back to user avatar" do
    @teacher.profile_picture.purge
    user = users(:one)
    user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    @teacher.update!(user: user)

    assert_not_nil @teacher.display_avatar
  end

  test "display_avatar falls back to user picture_url" do
    @teacher.profile_picture.purge
    user = users(:one)
    user.avatar.purge
    user.update!(picture_url: "http://example.com/pic.jpg")
    @teacher.update!(user: user)

    assert_equal "http://example.com/pic.jpg", @teacher.display_avatar
  end

  test "display_avatar returns nil if nothing available" do
    @teacher.profile_picture.purge
    @teacher.user = nil
    assert_nil @teacher.display_avatar
  end

  test "cropped_avatar uses crop coordinates if present" do
    @teacher.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    @teacher.update!(
      avatar_crop_x: 10,
      avatar_crop_y: 10,
      avatar_crop_width: 100,
      avatar_crop_height: 100
    )

    variant = @teacher.cropped_avatar
    assert variant.present?
  end

  test "using_user_avatar? returns true if user avatar or picture_url present" do
    user = users(:one)
    @teacher.update!(user: user)

    # Case 1: User has avatar
    user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    assert @teacher.using_user_avatar?

    # Case 2: User has picture_url
    user.avatar.purge
    user.update!(picture_url: "http://example.com")
    assert @teacher.using_user_avatar?

    # Case 3: Neither
    user.update!(picture_url: nil)
    assert_not @teacher.using_user_avatar?

    # Case 4: No user
    @teacher.update!(user: nil)
    assert_not @teacher.using_user_avatar?
  end

  test "update_assignments_count updates the counter" do
    @teacher.assignments.destroy_all # Clear existing
    assert_equal 0, @teacher.assignments_count

    project_type = ProjectType.create!(name: "Type")

    # Create assignments and lessons
    assignment1 = Assignment.create!(student: students(:one), project_name: "P1", project_type: project_type)
    assignment2 = Assignment.create!(student: students(:one), project_name: "P2", project_type: project_type)

    Lesson.create!(name: "L1", assignment: assignment1, teacher: @teacher)
    Lesson.create!(name: "L2", assignment: assignment1, teacher: @teacher) # Same assignment
    Lesson.create!(name: "L3", assignment: assignment2, teacher: @teacher)

    @teacher.update_assignments_count
    assert_equal 2, @teacher.reload.assignments_count
  end

  test "reset_all_counters resets counters for all teachers" do
    @teacher.assignments.destroy_all # Clear existing

    project_type = ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "P1", project_type: project_type)
    Lesson.create!(name: "L1", assignment: assignment, teacher: @teacher)

    # Manually mess up counters
    @teacher.update_columns(assignments_count: 0, tutorials_count: 0)

    # Create a tutorial to test tutorials_count reset
    Tutorial.create!(name: "T1", teacher: @teacher)

    Teacher.reset_all_counters

    @teacher.reload
    assert_equal 1, @teacher.assignments_count
    assert_equal 1, @teacher.tutorials_count
  end

  test "touch_assignments updates associated records updated_at" do
    project_type = ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: students(:one), project_name: "P1", project_type: project_type)
    lesson = Lesson.create!(name: "L1", assignment: assignment, teacher: @teacher)
    tutorial = Tutorial.create!(name: "T1", teacher: @teacher)

    original_assignment_time = assignment.updated_at
    original_lesson_time = lesson.updated_at
    original_tutorial_time = tutorial.updated_at

    travel 1.hour do
      # Trigger save to fire after_save callback
      @teacher.update!(name: "New Name")

      assert_not_equal original_assignment_time, assignment.reload.updated_at
      assert_not_equal original_lesson_time, lesson.reload.updated_at
      assert_not_equal original_tutorial_time, tutorial.reload.updated_at
    end
  end
end
