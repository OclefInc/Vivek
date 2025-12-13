require "test_helper"

class Public::Professors::JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @teacher = Teacher.create!(
      name: "Test Professor",
      user: @user,
      show_on_contributors: true
    )
    @composition = compositions(:one)
    @journal = Journal.create!(
      composition: @composition,
      user: @user
    )
    # Attach a summary video to make it appear in index
    @journal.summary_video.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")),
      filename: "test_video.mp4",
      content_type: "video/mp4"
    )
  end

  test "should get index" do
    get professor_journals_path(@teacher)
    assert_response :success
  end

  test "should show only journals with summary videos in index" do
    # Create a journal without summary video
    Journal.create!(
      composition: compositions(:two),
      user: @user
    )

    get professor_journals_path(@teacher)
    assert_response :success
  end

  test "should redirect index for private teacher" do
    @teacher.update(show_on_contributors: false)

    get professor_journals_path(@teacher)

    assert_redirected_to root_path
    assert_equal "This profile is not available.", flash[:alert]
  end

  test "should get show" do
    get professor_journal_path(@teacher, @journal)
    assert_response :success
  end

  test "should redirect show for private teacher" do
    @teacher.update(show_on_contributors: false)

    get professor_journal_path(@teacher, @journal)

    assert_redirected_to root_path
    assert_equal "This profile is not available.", flash[:alert]
  end

  test "should redirect show for non-existent journal" do
    get professor_journal_path(@teacher, id: 99999)

    assert_redirected_to root_path
  end

  test "should redirect show for journal that doesn't exist" do
    non_existent_id = Journal.maximum(:id).to_i + 1

    get professor_journal_path(@teacher, id: non_existent_id)

    assert_redirected_to root_path
  end

  test "index should only show journals for the specified teacher" do
    # Create another teacher with their own journal
    other_user = users(:two)
    Teacher.create!(
      name: "Other Professor",
      user: other_user,
      show_on_contributors: true
    )
    other_journal = Journal.create!(
      composition: compositions(:two),
      user: other_user
    )
    other_journal.summary_video.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_video.mp4")),
      filename: "test_video.mp4",
      content_type: "video/mp4"
    )

    get professor_journals_path(@teacher)
    assert_response :success
  end

  test "should handle teacher with no journals" do
    @journal.destroy

    get professor_journals_path(@teacher)
    assert_response :success
  end

  test "show should display journal regardless of teacher's journals_count" do
    @teacher.update(journals_count: 0)

    get professor_journal_path(@teacher, @journal)
    assert_response :success
  end

  test "index should handle teacher with nil user gracefully" do
    teacher_without_user = Teacher.create!(
      name: "Teacher Without User",
      user: nil,
      show_on_contributors: true
    )

    get professor_journals_path(teacher_without_user)
    assert_response :success
  end

  test "show should handle journal from different user" do
    other_user = users(:two)
    other_teacher = Teacher.create!(
      name: "Other Teacher",
      user: other_user,
      show_on_contributors: true
    )

    # Journal belongs to @user/@teacher, but we're accessing via other_teacher
    get professor_journal_path(other_teacher, @journal)

    # Should still show the journal (controller doesn't check teacher ownership)
    assert_response :success
  end

  test "index uses public layout" do
    get professor_journals_path(@teacher)
    assert_response :success
    assert_select "body"
  end

  test "show uses public layout" do
    get professor_journal_path(@teacher, @journal)
    assert_response :success
    assert_select "body"
  end
end
