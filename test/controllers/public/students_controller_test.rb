require "test_helper"

class Public::StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:one)
  end

  test "should get index" do
    get public_students_path
    assert_response :success
  end

  test "should only show public students in index" do
    private_student = Student.new(name: "Private Student", show_on_contributors: false)
    private_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    private_student.save!

    public_student = Student.new(name: "Public Student", show_on_contributors: true)
    public_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    public_student.save!

    get public_students_path
    assert_response :success
    assert_includes @response.body, "Public Student"
    assert_not_includes @response.body, "Private Student"
  end

  test "should get show" do
    get public_student_path(@student)
    assert_response :success
  end

  test "should redirect show when student is private" do
    private_student = Student.new(name: "Private Student", show_on_contributors: false)
    private_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    private_student.save!

    get public_student_path(private_student)

    assert_redirected_to root_path
    assert_equal "This profile is not available.", flash[:alert]
  end

  test "should show public student profile" do
    public_student = Student.new(name: "Public Student", show_on_contributors: true)
    public_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    public_student.save!

    get public_student_path(public_student)

    assert_response :success
    assert_includes @response.body, "Public Student"
  end
end
