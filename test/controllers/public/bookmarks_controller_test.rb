require "test_helper"

class Public::BookmarksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @bookmark = bookmarks(:one)
    @bookmark.update(user: @user)
    @bookmarkable = @bookmark.bookmarkable
  end

  test "should get index" do
    sign_in @user
    get public_bookmarks_path
    assert_response :success
  end

  test "should get button" do
    get button_public_bookmarks_path(bookmarkable_type: @bookmarkable.class.name, bookmarkable_id: @bookmarkable.id)
    assert_response :success
  end

  test "should create bookmark" do
    sign_in @user
    @bookmark.destroy

    assert_difference("Boo kmark.count") do
      post publ ic_bookmarks_path, params: { bo okmark: { bo okmarkable_id: @bookmarkable.id, bookmarkable_type: @bookmarkable.class.name } }
    end
    assert_redirected_to root _path
  end
  test "sho uld destroy bookmark" do
    sign_in @use r
    assert_difference("Boo kmark.count", -1) do
      delete publ ic_bookmark_path(@boo kmark)
    end
    assert_redirected_to root _path
  end
end
