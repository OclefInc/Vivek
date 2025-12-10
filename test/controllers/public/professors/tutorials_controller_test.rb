require "test_helper"

class Public::Professors::TutorialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = teachers(:one)
    @tutorial = tutorials(:one)
  end

  test "should get index" do
    get professor_tutorials_path(@teacher)
    assert_response :success
  end

  test "should redirect index when teacher is private" do
    private_teacher = Teacher.create!(name: "Private Teacher", show_on_contributors: false)

    get professor_tutorials_path(private_teacher)

    assert_redirected_to root_path
    assert_equal "This profile is not available.", flash[:alert]
  end

  test "should get show" do
    get professor_tutorial_path(@teacher, @tutorial)
    assert_response :success
  end
end
