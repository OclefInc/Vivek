require "test_helper"

class Public::ProfessorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
  end

  test "should get index" do
    get professors_path
    assert_response :success
  end

  test "should only show public teachers in index" do
    private_teacher = Teacher.new(name: "Private Teacher", show_on_contributors: false)
    private_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    private_teacher.save!

    public_teacher = Teacher.new(name: "Public Teacher", show_on_contributors: true)
    public_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    public_teacher.save!

    get professors_path
    assert_response :success
    assert_includes @response.body, "Public Teacher"
    assert_not_includes @response.body, "Private Teacher"
  end

  test "should get show" do
    get professor_path(@teacher)
    assert_response :success
  end

  test "should redirect show when teacher is private" do
    private_teacher = Teacher.new(name: "Private Teacher", show_on_contributors: false)
    private_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    private_teacher.save!

    get professor_path(private_teacher)

    assert_redirected_to root_path
    assert_equal "This profile is not available.", flash[:alert]
  end

  test "should show public teacher profile" do
    public_teacher = Teacher.new(name: "Public Teacher", show_on_contributors: true)
    public_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    public_teacher.save!

    get professor_path(public_teacher)

    assert_response :success
    assert_includes @response.body, "Public Teacher"
  end
end
