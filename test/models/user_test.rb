# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_crop_height     :integer
#  avatar_crop_width      :integer
#  avatar_crop_x          :integer
#  avatar_crop_y          :integer
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  magic_link_sent_at     :datetime
#  magic_link_token       :string
#  name                   :string
#  picture_url            :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_magic_link_token      (magic_link_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should link existing user with omniauth" do
    user = users(:one)
    # Use update_columns to bypass Devise reconfirmable logic which would put the new email in unconfirmed_email
    user.update_columns(provider: nil, uid: nil, email: "existing@example.com")

    auth = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456789",
      info: {
        email: "existing@example.com",
        name: "Google User",
        image: "http://example.com/image.jpg"
      }
    })

    assert_no_difference "User.count" do
      omniauth_user = User.from_omniauth(auth)
      assert_equal user.id, omniauth_user.id
      assert_equal "google_oauth2", omniauth_user.provider
      assert_equal "123456789", omniauth_user.uid
      assert_equal "http://example.com/image.jpg", omniauth_user.picture_url
    end
  end

  test "should link existing user with github omniauth" do
    user = users(:two)
    user.update_columns(provider: nil, uid: nil, email: "github_user@example.com")

    auth = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "987654321",
      info: {
        email: "github_user@example.com",
        name: "GitHub User",
        image: "http://example.com/github_image.jpg"
      }
    })

    assert_no_difference "User.count" do
      omniauth_user = User.from_omniauth(auth)
      assert_equal user.id, omniauth_user.id
      assert_equal "github", omniauth_user.provider
      assert_equal "987654321", omniauth_user.uid
    end
  end

  test "should create new user if email does not match" do
    auth = OmniAuth::AuthHash.new({
      provider: "facebook",
      uid: "555555555",
      info: {
        email: "new_facebook@example.com",
        name: "Facebook User",
        image: "http://example.com/fb_image.jpg"
      }
    })

    assert_difference "User.count", 1 do
      omniauth_user = User.from_omniauth(auth)
      assert_equal "facebook", omniauth_user.provider
      assert_equal "new_facebook@example.com", omniauth_user.email
    end
  end

  test "should allow login with multiple providers for same email" do
    email = "multi_provider@example.com"
    user = User.create!(
      email: email,
      name: "Multi User",
      password: "password",
      provider: "google_oauth2",
      uid: "google_123"
    )

    # 1. Login with GitHub (same email)
    github_auth = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "github_456",
      info: {
        email: email,
        name: "GitHub User",
        image: "http://example.com/gh.jpg"
      }
    })

    assert_no_difference "User.count" do
      github_user = User.from_omniauth(github_auth)
      assert_equal user.id, github_user.id
      assert_equal "github", github_user.provider
      assert_equal "github_456", github_user.uid
    end

    # 2. Login with Google again
    google_auth = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "google_123",
      info: {
        email: email,
        name: "Google User",
        image: "http://example.com/google.jpg"
      }
    })

    assert_no_difference "User.count" do
      google_user = User.from_omniauth(google_auth)
      assert_equal user.id, google_user.id
      assert_equal "google_oauth2", google_user.provider
      assert_equal "google_123", google_user.uid
    end
  end

  test "initials returns correct initials" do
    user = User.new(name: "John Doe")
    assert_equal "JD", user.initials

    user.name = "Jane"
    assert_equal "J", user.initials

    user.name = "John Von Neumann"
    assert_equal "JVN", user.initials
  end

  test "roles returns correct roles" do
    user = users(:one)

    # Initially no roles
    user.stubs(:is_employee?).returns(false)
    user.stubs(:is_student?).returns(false)
    user.stubs(:is_teacher?).returns(false)
    assert_empty user.roles

    # Employee
    user.stubs(:is_employee?).returns(true)
    assert_includes user.roles, "Employee"

    # Student
    user.stubs(:is_employee?).returns(false)
    user.stubs(:is_student?).returns(true)
    assert_includes user.roles, "Student"

    # Teacher
    user.stubs(:is_student?).returns(false)
    user.stubs(:is_teacher?).returns(true)
    assert_includes user.roles, "Teacher"
  end

  test "is_employee? returns true for oclef.com email" do
    user = User.new(email: "test@oclef.com")
    assert user.is_employee?

    user.email = "test@example.com"
    assert_not user.is_employee?
  end

  test "is_student? returns true if student record exists" do
    user = users(:one)
    assert_not user.is_student?

    student = Student.new(user_id: user.id, name: "Student Name")
    student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    student.save!

    assert user.is_student?
  end

  test "is_teacher? returns true if teacher record exists" do
    user = users(:one)
    assert_not user.is_teacher?

    Teacher.create!(user_id: user.id, name: "Teacher Name")
    assert user.is_teacher?
  end

  test "account_type returns correct string" do
    user = users(:one)

    # Guest
    user.stubs(:is_employee?).returns(false)
    user.stubs(:is_student?).returns(false)
    user.stubs(:is_teacher?).returns(false)
    # Reset memoized variable
    user.instance_variable_set(:@account_type, nil)
    assert_equal "Guest", user.account_type

    # Employee
    user.stubs(:is_employee?).returns(true)
    user.instance_variable_set(:@account_type, nil)
    assert_equal "Employee", user.account_type

    # Multiple roles
    user.stubs(:is_student?).returns(true)
    user.instance_variable_set(:@account_type, nil)
    assert_equal "Employee, Student", user.account_type
  end

  test "magic link methods" do
    user = users(:one)

    # generate_magic_link_token!
    user.generate_magic_link_token!
    assert_not_nil user.magic_link_token
    assert_not_nil user.magic_link_sent_at

    # magic_link_valid?
    assert user.magic_link_valid?

    user.magic_link_sent_at = 20.minutes.ago
    assert_not user.magic_link_valid?

    # send_magic_link
    # Mock mailer
    mail = mock
    mail.expects(:deliver_now)
    MagicLinkMailer.expects(:login_link).with(user).returns(mail)

    user.send_magic_link
  end

  test "oauth_user? returns true if provider and uid present" do
    user = User.new
    assert_not user.oauth_user?

    user.provider = "google"
    assert_not user.oauth_user?

    user.uid = "123"
    assert user.oauth_user?
  end

  test "touch_related_assignments touches student and teacher assignments" do
    user = users(:one)

    # Setup student and assignment
    student = Student.new(user_id: user.id, name: "Student")
    student.profile_picture.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    student.save!

    # Ensure ProjectType exists or create it
    project_type = ProjectType.first || ProjectType.create!(name: "Type")

    assignment = Assignment.create!(student: student, project_name: "Test Project", project_type: project_type)

    # Setup teacher and assignment
    teacher = Teacher.create!(user_id: user.id, name: "Teacher")
    # Create assignment for teacher (via lesson usually, but let's just check logic)
    # The code says: teacher.assignments.distinct.update_all
    # We need to associate assignment with teacher.
    # Assignment belongs_to teacher (optional)
    assignment2 = Assignment.create!(student: student, teacher: teacher, project_name: "Teacher Project", project_type: project_type)

    # Capture timestamps
    student_updated_at = student.updated_at
    assignment_updated_at = assignment.updated_at
    teacher_updated_at = teacher.updated_at
    assignment2_updated_at = assignment2.updated_at

    # Advance time
    travel 1.second do
      # Trigger callback (after_save)
      user.reload
      user.name = "Touched Name"
      user.save

      # Reload to check updates
      student.reload
      assignment.reload
      teacher.reload
      assignment2.reload

      assert_operator student.updated_at, :>, student_updated_at
      assert_operator assignment.updated_at, :>, assignment_updated_at
      assert_operator teacher.updated_at, :>, teacher_updated_at
      assert_operator assignment2.updated_at, :>, assignment2_updated_at
    end
  end

  test "cropped_avatar returns nil if no avatar attached" do
    user = users(:one)
    assert_nil user.cropped_avatar
  end

  test "cropped_avatar returns variant if avatar attached" do
    user = users(:one)
    user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")

    assert_not_nil user.cropped_avatar
    assert_kind_of ActiveStorage::VariantWithRecord, user.cropped_avatar
  end

  test "cropped_avatar uses crop coordinates if present" do
    user = users(:one)
    user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")

    user.avatar_crop_x = 10
    user.avatar_crop_y = 10
    user.avatar_crop_width = 100
    user.avatar_crop_height = 100

    assert_not_nil user.cropped_avatar
    assert_kind_of ActiveStorage::VariantWithRecord, user.cropped_avatar
  end

  test "password_required? logic" do
    user = User.new

    # Not oauth user, not persisted, password not present -> false (because !oauth_user?)
    # Wait: oauth_user? && !persisted?
    # If user is new and not oauth, password_required? is false?
    # Let's check logic: oauth_user? && !persisted? || password.present? || password_confirmation.present?

    # Case 1: New non-oauth user (Magic link user)
    user.provider = nil
    user.uid = nil
    assert_not user.password_required?

    # Case 2: New oauth user
    user.provider = "google"
    user.uid = "123"
    assert user.password_required?

    # Case 3: Persisted oauth user
    user.save(validate: false)
    assert_not user.password_required?

    # Case 4: Setting password explicitly
    user.password = "password"
    assert user.password_required?

    user.password = nil
    user.password_confirmation = "password"
    assert user.password_required?
  end

  test "email_required? returns true" do
    assert User.new.email_required?
  end
end
