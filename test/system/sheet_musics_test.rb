require "application_system_test_case"

class SheetMusicsTest < ApplicationSystemTestCase
  setup do
    @sheet_music = sheet_musics(:one)
  end

  test "visiting the index" do
    visit sheet_musics_url
    assert_selector "h1", text: "Sheet musics"
  end

  test "should create sheet music" do
    visit sheet_musics_url
    click_on "New sheet music"

    fill_in "Composition", with: @sheet_music.composition_id
    click_on "Create Sheet music"

    assert_text "Sheet music was successfully created"
    click_on "Back"
  end

  test "should update Sheet music" do
    visit sheet_music_url(@sheet_music)
    click_on "Edit this sheet music", match: :first

    fill_in "Composition", with: @sheet_music.composition_id
    click_on "Update Sheet music"

    assert_text "Sheet music was successfully updated"
    click_on "Back"
  end

  test "should destroy Sheet music" do
    visit sheet_music_url(@sheet_music)
    accept_confirm { click_on "Destroy this sheet music", match: :first }

    assert_text "Sheet music was successfully destroyed"
  end
end
