require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_path
    assert_response :success
  end

  test "should get about" do
    get about_path
    assert_response :success
  end

  test "should get contact" do
    get contact_path
    assert_response :success
  end

  test "should get contributors" do
    get contributors_path
    assert_response :success
  end

  test "contributors page only displays students with show_on_contributors true" do
    # Create students with show_on_contributors true and false
    visible_student = Student.new(
      name: "Visible Student",
      show_on_contributors: true
    )
    visible_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    visible_student.save!

    hidden_student = Student.new(
      name: "Hidden Student",
      show_on_contributors: false
    )
    hidden_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    hidden_student.save!

    get contributors_path

    assert_response :success
    assert_select "h2", text: "Students"

    # Check that visible student appears in the response
    assert_includes @response.body, "Visible Student"

    # Check that hidden student does NOT appear in the response
    assert_not_includes @response.body, "Hidden Student"
  end

  test "contributors page only displays teachers with show_on_contributors true" do
    # Create teachers with show_on_contributors true and false
    visible_teacher = Teacher.new(
      name: "Visible Teacher",
      show_on_contributors: true
    )
    visible_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    visible_teacher.save!

    hidden_teacher = Teacher.new(
      name: "Hidden Teacher",
      show_on_contributors: false
    )
    hidden_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    hidden_teacher.save!

    get contributors_path

    assert_response :success
    assert_select "h2", text: "Teachers"

    # Check that visible teacher appears in the response
    assert_includes @response.body, "Visible Teacher"

    # Check that hidden teacher does NOT appear in the response
    assert_not_includes @response.body, "Hidden Teacher"
  end

  test "contributors controller assigns only visible students and teachers" do
    # Create mix of visible and hidden
    visible_student = Student.new(
      name: "Visible Student ZZZ",
      show_on_contributors: true
    )
    visible_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    visible_student.save!

    hidden_student = Student.new(
      name: "Hidden Student AAA",
      show_on_contributors: false
    )
    hidden_student.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    hidden_student.save!

    visible_teacher = Teacher.new(
      name: "Visible Teacher ZZZ",
      show_on_contributors: true
    )
    visible_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    visible_teacher.save!

    hidden_teacher = Teacher.new(
      name: "Hidden Teacher AAA",
      show_on_contributors: false
    )
    hidden_teacher.profile_picture.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
    hidden_teacher.save!

    get contributors_path

    # Check that only visible ones appear in the response
    assert_includes @response.body, "Visible Student ZZZ"
    assert_not_includes @response.body, "Hidden Student AAA"
    assert_includes @response.body, "Visible Teacher ZZZ"
    assert_not_includes @response.body, "Hidden Teacher AAA"
  end
end
