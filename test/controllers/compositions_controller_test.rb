require "test_helper"

class CompositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @composition = compositions(:one)
  end

  test "should get index" do
    get compositions_url
    assert_response :success
  end

  test "should get new" do
    get new_composition_url
    assert_response :success
  end

  test "should create composition" do
    assert_difference("Composition.count") do
      post compositions_url, params: { composition: { composer: @composition.composer, name: @composition.name } }
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
    patch composition_url(@composition), params: { composition: { composer: @composition.composer, name: @composition.name } }
    assert_redirected_to composition_url(@composition)
  end

  test "should destroy composition" do
    assert_difference("Composition.count", -1) do
      delete composition_url(@composition)
    end

    assert_redirected_to compositions_url
  end
end
