require "test_helper"

class Admin::Journals::JournalEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @journal = journals(:one)
    @journal_entry = journal_entries(:one)
  end

  test "should get index" do
    get journal_journal_entries_url(@journal)
    assert_response :success
  end

  test "should get show" do
    get journal_journal_entry_url(@journal, @journal_entry)
    assert_response :success
  end

  test "should get new" do
    get new_journal_journal_entry_url(@journal)
    assert_response :success
  end

  test "should get edit" do
    get edit_journal_journal_entry_url(@journal, @journal_entry)
    assert_response :success
  end

  test "should get edit with field parameter" do
    get edit_journal_journal_entry_url(@journal, @journal_entry), params: { field: "name" }
    assert_response :success
  end

  test "should create journal_entry" do
    assert_difference("JournalEntry.count") do
      post journal_journal_entries_url(@journal), params: { journal_entry: { name: "Test Entry", date: Date.today } }
    end

    assert_redirected_to journal_journal_entry_url(@journal, JournalEntry.last)
  end

  test "should not create journal_entry with invalid params" do
    assert_no_difference("JournalEntry.count") do
      post journal_journal_entries_url(@journal), params: { journal_entry: { name: "", date: nil } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create journal_entry with invalid params as json" do
    assert_no_difference("JournalEntry.count") do
      post journal_journal_entries_url(@journal, format: :json), params: { journal_entry: { name: "", date: nil } }
    end

    assert_response :unprocessable_entity
  end

  test "should update journal_entry" do
    patch journal_journal_entry_url(@journal, @journal_entry), params: { journal_entry: { name: "Updated Entry" } }
    @journal_entry.reload
    assert_redirected_to journal_journal_entry_url(@journal, @journal_entry)
  end

  test "should not update journal_entry with invalid params" do
    patch journal_journal_entry_url(@journal, @journal_entry), params: { journal_entry: { name: "", date: nil } }
    assert_response :unprocessable_entity
  end

  test "should not update journal_entry with invalid params as json" do
    patch journal_journal_entry_url(@journal, @journal_entry, format: :json), params: { journal_entry: { name: "", date: nil } }
    assert_response :unprocessable_entity
  end

  test "should destroy journal_entry" do
    assert_difference("JournalEntry.count", -1) do
      delete journal_journal_entry_url(@journal, @journal_entry)
    end

    assert_redirected_to journal_journal_entries_url(@journal)
  end

  test "should create journal_entry with unwrapped params" do
    assert_difference("JournalEntry.count") do
      post journal_journal_entries_url(@journal), params: { name: "Unwrapped Entry", date: Date.today }
    end

    assert_redirected_to journal_journal_entry_url(@journal, JournalEntry.last)
  end
end
