require "test_helper"

class Api::ProfessorsLookupTest < ActionDispatch::IntegrationTest
  test "returns professor projects presentations and learning journals" do
    teacher = teachers(:teacher_with_user)
    user = users(:one)
    tutorial = tutorials(:one)

    # Ensure at least one project is connected to this professor through lessons.
    Lesson.create!(assignment: assignments(:one), teacher: teacher, name: "Lookup Lesson", date: Date.current)
    tutorial.video_file.attach(
      io: file_fixture("test_video.mp4").open,
      filename: "test_video.mp4",
      content_type: "video/mp4"
    )

    post "/api/professors/lookup", params: { email: user.email }, as: :json

    assert_response :success

    payload = JSON.parse(response.body)

    assert_equal user.email, payload["email"]
    assert_equal teacher.id, payload.dig("professor", "id")
    assert_equal teacher.name, payload.dig("professor", "name")

    assert payload["projects"].any? { |project| project["id"] == assignments(:one).id }
    assert payload["presentations"].any? { |presentation| presentation["id"] == tutorial.id }
    assert payload["learning_journals"].any? { |journal| journal["id"] == journals(:one).id }
  end

  test "returns not found when user is not a professor" do
    post "/api/professors/lookup", params: { email: users(:two).email }, as: :json

    assert_response :not_found
    assert_equal "Professor not found", JSON.parse(response.body)["error"]
  end

  test "returns unprocessable entity when email is missing" do
    post "/api/professors/lookup", params: {}, as: :json

    assert_response :unprocessable_entity
    assert_equal "email is required", JSON.parse(response.body)["error"]
  end
end
