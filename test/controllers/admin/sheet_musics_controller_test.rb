require "test_helper"
require "mocha/minitest"

class Admin::SheetMusicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @composition = compositions(:one)
    @sheet_music = sheet_musics(:one)
    file = fixture_file_upload("test_pdf.pdf", "application/pdf")
    @sheet_music.pdf_file.attach(io: file, filename: "test_pdf.pdf", content_type: "application/pdf")
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get sheet_musics_url(composition_id: @composition.id)
    assert_response :success
  end

  test "should get new" do
    get new_sheet_music_url(composition_id: @composition.id)
    assert_response :success
  end

  test "should create sheet_music" do
    file = fixture_file_upload("test_pdf.pdf", "application/pdf")
    assert_difference("SheetMusic.count") do
      post sheet_musics_url, params: { sheet_music: { composition_id: @composition.id, pdf_file: file } }
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
    patch sheet_music_url(@sheet_music), params: { sheet_music: { composition_id: @composition.id } }
    assert_redirected_to sheet_music_url(@sheet_music)
  end

  test "should destroy sheet_music" do
    assert_difference("SheetMusic.count", -1) do
      delete sheet_music_url(@sheet_music)
    end
    assert_redirected_to sheet_musics_url
  end

  test "should fail to create sheet_music" do
    assert_no_difference("SheetMusic.count") do
      post sheet_musics_url, params: { sheet_music: { composition_id: @composition.id } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to create sheet_music json" do
    assert_no_difference("SheetMusic.count") do
      post sheet_musics_url(format: :json), params: { sheet_music: { composition_id: @composition.id } }
    end
    assert_response :unprocessable_entity
  end

  test "should fail to update sheet_music" do
    patch sheet_music_url(@sheet_music), params: { sheet_music: { composition_id: nil } }
    assert_response :unprocessable_entity
  end

  test "should fail to update sheet_music json" do
    patch sheet_music_url(@sheet_music, format: :json), params: { sheet_music: { composition_id: nil } }
    assert_response :unprocessable_entity
  end

  test "should destroy sheet_music json" do
    delete sheet_music_url(@sheet_music, format: :json)
    assert_response :no_content
  end
end
