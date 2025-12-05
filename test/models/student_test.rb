# == Schema Information
#
# Table name: students
#
#  id                 :bigint           not null, primary key
#  age_started_piano  :integer
#  assignments_count  :integer          default(0), not null
#  avatar_crop_height :integer
#  avatar_crop_width  :integer
#  avatar_crop_x      :integer
#  avatar_crop_y      :integer
#  lessons_count      :integer          default(0), not null
#  name               :string
#  year_of_birth      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  setup do
    @student = students(:one)
    @file = File.open(Rails.root.join("test/fixtures/files/test_image.png"))
    @student.profile_picture.attach(io: @file, filename: "test_image.png", content_type: "image/png")
    @student.save!
  end

  teardown do
    @file.close
  end

  test "validates presence of name" do
    @student.name = nil
    assert_not @student.valid?
    assert_includes @student.errors[:name], "can't be blank"
  end

  test "validates presence of profile_picture" do
    @student.profile_picture.purge
    assert_not @student.valid?
    assert_includes @student.errors[:profile_picture], "can't be blank"
  end

  test "validates profile_picture is image type" do
    @student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")), filename: "video.mp4", content_type: "video/mp4")
    assert_not @student.valid?
    assert_includes @student.errors[:profile_picture], "must be an image file"
  end

  test "to_param returns id-name-parameterized" do
    @student.update!(name: "John Doe")
    assert_equal "#{@student.id}-john-doe", @student.to_param
  end

  test "initials returns initials" do
    @student.update!(name: "John Doe")
    assert_equal "JD", @student.initials

    @student.update!(name: "Single")
    assert_equal "S", @student.initials
  end

  test "display_avatar returns profile picture variant if attached" do
    assert_not_nil @student.display_avatar
    # It returns a variant, so we can check if it's a variant or check properties
    assert @student.display_avatar.is_a?(ActiveStorage::Variant) || @student.display_avatar.is_a?(ActiveStorage::VariantWithRecord)
  end

  test "display_avatar falls back to user avatar" do
    @student.profile_picture.purge
    user = users(:one)
    user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")

    # Assign user in memory without saving to avoid validation error
    @student.user = user

    assert_not_nil @student.display_avatar
    # Should be user's avatar variant
  end

  test "display_avatar falls back to user picture_url" do
    @student.profile_picture.purge
    user = users(:one)
    user.avatar.purge
    user.update!(picture_url: "http://example.com/pic.jpg")

    # Assign user in memory
    @student.user = user

    assert_equal "http://example.com/pic.jpg", @student.display_avatar
  end

  test "display_avatar returns nil if nothing available" do
    @student.profile_picture.purge
    @student.user = nil
    assert_nil @student.display_avatar
  end

  test "cropped_avatar uses crop coordinates if present" do
    @student.assign_attributes(
      avatar_crop_x: 10,
      avatar_crop_y: 10,
      avatar_crop_width: 100,
      avatar_crop_height: 100
    )

    variant = @student.cropped_avatar
    assert variant.present?
  end

  test "using_user_avatar? returns true if user avatar or picture_url present" do
    user = users(:one)
    @student.user = user # In memory assignment

    # Case 1: User has avatar
    user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    assert @student.using_user_avatar?

    # Case 2: User has picture_url
    user.avatar.purge
    user.update!(picture_url: "http://example.com")
    assert @student.using_user_avatar?

    # Case 3: Neither
    user.update!(picture_url: nil)
    assert_not @student.using_user_avatar?

    # Case 4: No user
    @student.user = nil
    assert_not @student.using_user_avatar?
  end

  test "update_lessons_count updates the counter" do
    @student.assignments.destroy_all # Clear existing
    assert_equal 0, @student.lessons_count

    project_type = ProjectType.create!(name: "Type")

    # Create assignments and lessons
    assignment = Assignment.create!(student: @student, project_name: "P1", project_type: project_type)
    Lesson.create!(name: "L1", assignment: assignment)
    Lesson.create!(name: "L2", assignment: assignment)

    @student.update_lessons_count
    assert_equal 2, @student.reload.lessons_count
  end

  test "reset_all_counters resets counters for all students" do
    @student.assignments.destroy_all # Clear existing

    project_type = ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: @student, project_name: "P1", project_type: project_type)
    Lesson.create!(name: "L1", assignment: assignment)

    # Manually mess up counters
    @student.update_columns(assignments_count: 0, lessons_count: 0)

    Student.reset_all_counters

    @student.reload
    assert_equal 1, @student.assignments_count
    assert_equal 1, @student.lessons_count
  end

  test "touch_assignments updates assignments updated_at" do
    project_type = ProjectType.create!(name: "Type")
    assignment = Assignment.create!(student: @student, project_name: "P1", project_type: project_type)
    original_time = assignment.updated_at

    travel 1.hour do
      # Trigger save to fire after_save callback
      @student.update!(name: "New Name")
      assert_not_equal original_time, assignment.reload.updated_at
    end
  end
end
