require "test_helper"

class Public::Professors::Journals::JournalEntriesControllerTest < ActionDispatch::IntegrationTest
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
    @journal_entry = JournalEntry.create!(
      journal: @journal,
      name: "Test Entry",
      date: Date.today,
      sort: 1
    )
  end

  test "should get show" do
    get professor_journal_journal_entry_path(@teacher, @journal, @journal_entry)
    assert_response :success
  end

  test "should redirect show for private teacher" do
    @teacher.update(show_on_contributors: false)

    get professor_journal_journal_entry_path(@teacher, @journal, @journal_entry)

    assert_redirected_to root_path
    assert_equal "This profile is not available.", flash[:alert]
  end

  test "should redirect show for invalid journal entry" do
    get professor_journal_journal_entry_path(@teacher, @journal, id: -1)

    assert_redirected_to root_path
  end
end
