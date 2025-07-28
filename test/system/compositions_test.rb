require "application_system_test_case"

class CompositionsTest < ApplicationSystemTestCase
  setup do
    @composition = compositions(:one)
  end

  test "visiting the index" do
    visit compositions_url
    assert_selector "h1", text: "Compositions"
  end

  test "should create composition" do
    visit compositions_url
    click_on "New composition"

    fill_in "Composer", with: @composition.composer
    fill_in "Name", with: @composition.name
    click_on "Create Composition"

    assert_text "Composition was successfully created"
    click_on "Back"
  end

  test "should update Composition" do
    visit composition_url(@composition)
    click_on "Edit this composition", match: :first

    fill_in "Composer", with: @composition.composer
    fill_in "Name", with: @composition.name
    click_on "Update Composition"

    assert_text "Composition was successfully updated"
    click_on "Back"
  end

  test "should destroy Composition" do
    visit composition_url(@composition)
    accept_confirm { click_on "Destroy this composition", match: :first }

    assert_text "Composition was successfully destroyed"
  end
end
