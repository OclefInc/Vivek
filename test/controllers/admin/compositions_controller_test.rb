require "test_helper"
require "mocha/minitest"

class Admin::CompositionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @composition = compositions(:one)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get compositions_url
    assert_response :success
  end

  test "should search compositions" do
    get compositions_url(query: @composition.name)
    assert_response :success
    assert_select "td", @composition.name
  end

  test "should get new" do
    get new_composition_url
    assert_response :success
  end

  test "should create composition" do
    assert_difference("Composition.count") do
      post compositions_url, params: { composition: { name: "New Composition", composer: "Composer", description: "Desc" } }
    end
    assert_redirected_to composition_url(Composition.last)
  end

  test "should show composition" do
    get composition_url(@composition)
    assert_response :success
  end

  test "should get edit" do
    get edit_composition_url(@composition)
    assert_response :success
  end

  test "should update composition" do
    patch composition_url(@composition), params: { composition: { name: "Updated Composition" } }
    assert_redirected_to composition_url(@composition)
    @composition.reload
    assert_equal "Updated Composition", @composition.name
  end

  test "should destroy composition" do
    # Create a new composition that's not referenced by any journals
    composition = Composition.create!(name: "Deletable Composition", composer: "Test Composer")

    assert_difference("Composition.count", -1) do
      delete composition_url(composition)
    end
    assert_redirected_to compositions_url
  end

  test "should fail to create composition" do
    assert_no_difference("Composition.count") do
      post compositions_url, params: { composition: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to create composition json" do
    assert_no_difference("Composition.count") do
      post compositions_url(format: :json), params: { composition: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to update composition" do
    patch composition_url(@composition), params: { composition: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should fail to update composition json" do
    patch composition_url(@composition, format: :json), params: { composition: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy composition json" do
    # Create a new composition that's not referenced by any journals
    composition = Composition.create!(name: "Deletable Composition JSON", composer: "Test Composer")

    delete composition_url(composition, format: :json)
    assert_response :no_content
  end
end
