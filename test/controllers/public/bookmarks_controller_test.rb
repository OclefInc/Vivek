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

    assert_difference("Bookmark.count") do
      post public_bookmarks_path, params: { bookmark: { bookmarkable_id: @bookmarkable.id, bookmarkable_type: @bookmarkable.class.name } }
    end
    assert_redirected_to root_path
  end

  test "should fail to create bookmark" do
    sign_in @user

    assert_no_difference("Bookmark.count") do
      post public_bookmarks_path, params: { bookmark: { bookmarkable_id: nil, bookmarkable_type: @bookmarkable.class.name } }
    end

    assert_redirected_to root_path
    assert_equal "Unable to bookmark.", flash[:alert]
  end

  test "should destroy bookmark" do
    sign_in @user
    assert_difference("Bookmark.count", -1) do
      delete public_bookmark_path(@bookmark)
    end
    assert_redirected_to root_path
  end
end
