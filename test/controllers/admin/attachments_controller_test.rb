require "test_helper"

class Admin::AttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    file = fixture_file_upload("test_image.png", "image/png")
    @student = students(:one)
    @student.profile_picture.attach(io: file, filename: "test_image.png", content_type: "image/png")
    @blob = @student.reload.profile_picture.blob
  end

  test "should get edit_metadata" do
    get "/admin/attachments/#{@blob.signed_id}/edit_metadata"
    assert_response :success
  end

  test "should update metadata" do
    post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: true, purchase_url: "http://example.com" }
    assert_response :success
    @blob.reload
    assert @blob.metadata["copyrighted"]
    assert_equal "http://example.com", @blob.metadata["purchase_url"]
  end
end
