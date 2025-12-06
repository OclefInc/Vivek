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
    post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: true, purchase_url: "http://example.com" }, as: :json
    assert_response :success
    @blob.reload
    assert_equal true, @blob.metadata["copyrighted"]
    assert_equal "http://example.com", @blob.metadata["purchase_url"]
  end

  test "should update metadata without purchase_url" do
    post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: false }, as: :json
    assert_response :success
    @blob.reload
    assert_equal false, @blob.metadata["copyrighted"]
  end

  test "should update metadata and touch associated objects" do
    # Setup ActionText association
    student = students(:two)
    # Attach profile picture to satisfy validation
    file = fixture_file_upload("test_image.png", "image/png")
    student.profile_picture.attach(io: file, filename: "test_image.png", content_type: "image/png")

    # Create a rich text content that embeds the blob
    # We use the blob's key to match the LIKE query in the controller
    student.bio = ActionText::Content.new("<div><action-text-attachment sgid='#{@blob.attachable_sgid}'></action-text-attachment></div>")
    student.save!

    original_updated_at = student.updated_at

    # Ensure time passes
    travel 1.second do
      post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: true }
    end

    assert_response :success
    assert_not_equal original_updated_at, student.reload.updated_at
  end

  test "should touch associated assignment when updating metadata" do
    assignment = assignments(:one)

    # Create a rich text content that embeds the blob in the assignment description
    assignment.description = ActionText::Content.new("<div><action-text-attachment sgid='#{@blob.attachable_sgid}'></action-text-attachment></div>")
    assignment.save!

    original_updated_at = assignment.updated_at

    # Ensure time passes
    travel 1.second do
      post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: true }
    end

    assert_response :success
    assert_not_equal original_updated_at, assignment.reload.updated_at
  end

  test "should handle invalid sgid for update_metadata" do
    post "/admin/attachments/update_metadata", params: { sgid: "invalid" }
    assert_response :not_found
    assert_equal "Blob not found", JSON.parse(response.body)["error"]
  end

  test "should handle exception in update_metadata" do
    ActiveStorage::Blob.stubs(:find_signed).raises(StandardError.new("Something went wrong"))
    post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id }
    assert_response :unprocessable_entity
    assert_equal "Something went wrong", JSON.parse(response.body)["error"]
  end

  test "should update pages" do
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_type: @student.class.name,
      record_id: @student.id
    }
    assert_response :success

    attachment = @blob.attachments.find_by(record: @student)
    assert_equal "1-5", attachment.pages
  end

  test "should handle missing parameters for update_pages" do
    # Missing record_type/id
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5"
    }
    assert_response :unprocessable_entity
    assert_equal "Missing required parameters", JSON.parse(response.body)["error"]

    # Invalid sgid
    post "/admin/attachments/update_pages", params: {
      sgid: "invalid",
      pages: "1-5",
      record_type: @student.class.name,
      record_id: @student.id
    }
    assert_response :unprocessable_entity
    assert_equal "Missing required parameters", JSON.parse(response.body)["error"]
  end

  test "should handle exception in update_pages" do
    ActiveStorage::Blob.stubs(:find_signed).raises(StandardError.new("Something went wrong"))
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_type: @student.class.name,
      record_id: @student.id
    }
    assert_response :unprocessable_entity
    assert_equal "Something went wrong", JSON.parse(response.body)["error"]
  end

  test "should not update pages if attachment not found" do
    # Create another student who is NOT attached to the blob
    other_student = students(:two)

    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_type: other_student.class.name,
      record_id: other_student.id
    }
    assert_response :success
  end

  test "should handle rich text in touch_associated_objects" do
    student = students(:two)
    # Create orphaned rich text
    rich_text = ActionText::RichText.new(
      name: "bio",
      body: ActionText::Content.new("<div><action-text-attachment sgid='#{@blob.key}'></action-text-attachment></div>"),
      record_type: "Student",
      record_id: student.id
    )
    rich_text.save!(validate: false)

    post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: true }, as: :json
    assert_response :success
  end

  test "should handle orphaned rich text in touch_associated_objects" do
    # Create orphaned rich text
    rich_text = ActionText::RichText.new(
      name: "bio",
      body: ActionText::Content.new("<div><action-text-attachment sgid='#{@blob.attachable_sgid}'></action-text-attachment></div>"),
      record_type: "Student",
      record_id: 999999 # Non-existent ID
    )
    rich_text.save!(validate: false)

    post "/admin/attachments/update_metadata", params: { sgid: @blob.signed_id, copyrighted: true }, as: :json
    assert_response :success
  end

  test "should update metadata with no associated objects" do
    # Create a blob attached directly to a student (not via RichText)
    # This ensures the blob is valid/persisted but touch_associated_objects (which queries RichText) finds nothing.
    student = students(:two)
    file = fixture_file_upload("test_image.png", "image/png")
    student.profile_picture.attach(io: file, filename: "direct_attach.png", content_type: "image/png")
    blob = student.profile_picture.blob

    post "/admin/attachments/update_metadata", params: { sgid: blob.signed_id, copyrighted: true }, as: :json
    assert_response :success
  end

  test "should handle invalid record_type in update_pages" do
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_type: "InvalidClass",
      record_id: 1
    }
    assert_response :unprocessable_entity
  end

  test "should handle missing record_id in update_pages" do
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_type: "Student"
    }
    assert_response :unprocessable_entity
    assert_equal "Missing required parameters", JSON.parse(response.body)["error"]
  end

  test "should handle missing record_type in update_pages" do
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_id: 1
    }
    assert_response :unprocessable_entity
    assert_equal "Missing required parameters", JSON.parse(response.body)["error"]
  end

  test "should handle case where attachment is not found in update_pages" do
    # Create a blob attached to student two
    student_two = students(:two)
    file = fixture_file_upload("test_image.png", "image/png")
    student_two.profile_picture.attach(io: file, filename: "student_two.png", content_type: "image/png")
    blob = student_two.profile_picture.blob

    # Try to update pages for student one (who is not associated with this blob)
    student_one = students(:one)

    post "/admin/attachments/update_pages", params: {
      sgid: blob.signed_id,
      pages: "1-5",
      record_type: "Student",
      record_id: student_one.id
    }

    assert_response :success
    # Verify nothing crashed, but also nothing happened (hard to verify "nothing happened" other than success response)
  end

  test "should handle non-existent record in update_pages" do
    post "/admin/attachments/update_pages", params: {
      sgid: @blob.signed_id,
      pages: "1-5",
      record_type: "Student",
      record_id: -1
    }
    assert_response :unprocessable_entity
    assert_equal "Missing required parameters", JSON.parse(response.body)["error"]
  end
end
