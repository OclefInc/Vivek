require "test_helper"

class Admin::JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @journal = journals(:one)
  end

  test "should get index" do
    get journals_url
    assert_response :success
  end

  test "should get show" do
    get journal_url(@journal)
    assert_response :success
  end

  test "should get new" do
    get new_journal_url
    assert_response :success
  end

  test "should get edit" do
    get edit_journal_url(@journal)
    assert_response :success
  end

  test "should get edit with field parameter" do
    get edit_journal_url(@journal), params: { field: "composition" }
    assert_response :success
  end

  test "should create journal" do
    assert_difference("Journal.count") do
      post journals_url, params: { journal: { composition_name: compositions(:one).name } }
    end

    assert_redirected_to journal_url(Journal.last)
  end

  test "should create journal with new composition name" do
    new_composition_name = "Brand New Composition #{Time.now.to_i}"

    assert_difference(["Journal.count", "Composition.count"]) do
      post journals_url, params: { journal: { composition_name: new_composition_name } }
    end

    assert_redirected_to journal_url(Journal.last)
    assert_equal new_composition_name, Journal.last.composition.name
  end

  test "should not create journal with invalid params" do
    Journal.any_instance.stubs(:save).returns(false)

    assert_no_difference("Journal.count") do
      post journals_url, params: { journal: { composition_name: compositions(:one).name } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create journal with invalid params as json" do
    Journal.any_instance.stubs(:save).returns(false)

    assert_no_difference("Journal.count") do
      post journals_url(format: :json), params: { journal: { composition_name: compositions(:one).name } }
    end

    assert_response :unprocessable_entity
  end

  test "should update journal" do
    patch journal_url(@journal), params: { journal: { composition_id: @journal.composition_id } }
    assert_redirected_to journal_url(@journal)
  end

  test "should update journal with new composition name" do
    new_composition_name = "Updated New Composition #{Time.now.to_i}"

    assert_difference("Composition.count") do
      patch journal_url(@journal), params: { journal: { composition_name: new_composition_name } }
    end

    @journal.reload
    assert_redirected_to journal_url(@journal)
    assert_equal new_composition_name, @journal.composition.name
  end

  test "should not update journal with invalid params" do
    Journal.any_instance.stubs(:save).returns(false)

    patch journal_url(@journal), params: { journal: { composition_name: compositions(:one).name } }
    assert_response :unprocessable_entity
  end

  test "should not update journal with invalid params as json" do
    Journal.any_instance.stubs(:save).returns(false)

    patch journal_url(@journal, format: :json), params: { journal: { composition_name: compositions(:one).name } }
    assert_response :unprocessable_entity
  end

  test "should destroy journal" do
    assert_difference("Journal.count", -1) do
      delete journal_url(@journal)
    end

    assert_redirected_to journals_url
  end
end
