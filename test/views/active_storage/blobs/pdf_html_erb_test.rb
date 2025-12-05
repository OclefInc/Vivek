require "test_helper"

class ActiveStorage::Blobs::PdfHtmlErbTest < ActionView::TestCase
  setup do
    # Create a blob
    @blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("test/fixtures/files/test_pdf.pdf")),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    # Create an attachment (ActiveStorage::Attachment)
    # Use SheetMusic as it allows PDF attachments
    @sheet_music = SheetMusic.new(composition: Composition.create!(name: "Comp", composer: "Bach"))
    @sheet_music.pdf_file.attach(@blob)
    @sheet_music.save!

    @attachment = ActiveStorage::Attachment.where(blob_id: @blob.id).last

    # Set pages metadata
    @attachment.pages = "1-5"
    @attachment.save!
  end

  test "renders pdf viewer with correct data attributes" do
    render partial: "active_storage/blobs/pdf", locals: {
      blob: @blob,
      attachment: @attachment,
      is_copyrighted: false,
      purchase_url: nil,
      allow_edit_pages: true
    }

    assert_select "div[data-controller='pdf-viewer']" do
      assert_select "[data-pdf-viewer-url-value=?]", url_for(@blob)
      assert_select "[data-pdf-viewer-copyrighted-value='false']"
      assert_select "[data-pdf-viewer-pages-value='1-5']"
    end

    assert_select "div[data-copyright-banner]" do
      assert_select "p", text: "Non Copyrighted Material"
      assert_select "span#pages-display", text: "1-5"
      assert_select "a", text: "Click Here" # Download link
    end
  end

  test "renders copyrighted banner when copyrighted" do
    render partial: "active_storage/blobs/pdf", locals: {
      blob: @blob,
      attachment: @attachment,
      is_copyrighted: true,
      purchase_url: "http://example.com/buy",
      allow_edit_pages: true
    }

    assert_select "div[data-controller='pdf-viewer']" do
      assert_select "[data-pdf-viewer-copyrighted-value='true']"
    end

    assert_select "div[data-copyright-banner]" do
      assert_select "p", text: "Copyrighted Material"
      assert_select "a[href='http://example.com/buy']", text: "Click Here"
    end
  end

  test "displays 'All' pages when pages is blank" do
    @attachment.pages = nil

    render partial: "active_storage/blobs/pdf", locals: {
      blob: @blob,
      attachment: @attachment,
      is_copyrighted: false,
      purchase_url: nil,
      allow_edit_pages: true
    }

    assert_select "span#pages-display", text: "All"
  end

  test "shows edit pages button when allow_edit_pages is true" do
    render partial: "active_storage/blobs/pdf", locals: {
      blob: @blob,
      attachment: @attachment,
      is_copyrighted: false,
      purchase_url: nil,
      allow_edit_pages: true
    }

    assert_select "button[data-attachment-pages-target='editButton']", text: "Edit Pages to Display"
  end

  test "hides edit pages button when allow_edit_pages is false" do
    render partial: "active_storage/blobs/pdf", locals: {
      blob: @blob,
      attachment: @attachment,
      is_copyrighted: false,
      purchase_url: nil,
      allow_edit_pages: false
    }

    assert_select "button[data-attachment-pages-target='editButton']", count: 0
  end
end
