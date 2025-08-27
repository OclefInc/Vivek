require "test_helper"

class SheetMusicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sheet_music = sheet_musics(:one)
  end

  test "should get index" do
    get sheet_musics_url
    assert_response :success
  end

  test "should get new" do
    get new_sheet_music_url
    assert_response :success
  end

  test "should create sheet_music" do
    assert_difference("SheetMusic.count") do
      post sheet_musics_url, params: { sheet_music: { composition_id: @sheet_music.composition_id } }
    end

    assert_redirected_to sheet_music_url(SheetMusic.last)
  end

  test "should show sheet_music" do
    get sheet_music_url(@sheet_music)
    assert_response :success
  end

  test "should get edit" do
    get edit_sheet_music_url(@sheet_music)
    assert_response :success
  end

  test "should update sheet_music" do
    patch sheet_music_url(@sheet_music), params: { sheet_music: { composition_id: @sheet_music.composition_id } }
    assert_redirected_to sheet_music_url(@sheet_music)
  end

  test "should destroy sheet_music" do
    assert_difference("SheetMusic.count", -1) do
      delete sheet_music_url(@sheet_music)
    end

    assert_redirected_to sheet_musics_url
  end
end
