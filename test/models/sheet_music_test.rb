# == Schema Information
#
# Table name: sheet_musics
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  composition_id :integer
#
require "test_helper"

class SheetMusicTest < ActiveSupport::TestCase
  setup do
    @sheet_music = sheet_musics(:one)
    @composition = Composition.create!(name: "Moonlight Sonata", composer: "Beethoven")

    # Attach file first before saving/updating to satisfy validation
    @file = File.open(Rails.root.join("test/fixtures/files/test_pdf.pdf"))
    @sheet_music.pdf_file.attach(io: @file, filename: "test_pdf.pdf", content_type: "application/pdf")

    @sheet_music.update!(composition: @composition)
  end

  teardown do
    @file.close
  end

  test "validates presence of pdf_file" do
    @sheet_music.pdf_file.purge
    assert_not @sheet_music.valid?
    assert_includes @sheet_music.errors[:pdf_file], "can't be blank"
  end

  test "validates pdf_file is pdf type" do
    @sheet_music.pdf_file.attach(io: File.open(Rails.root.join("test/fixtures/files/test_image.png")), filename: "image.png", content_type: "image/png")
    assert_not @sheet_music.valid?
    assert_includes @sheet_music.errors[:pdf_file], "must be a PDF file"
  end

  test "project_name returns composition name" do
    assert_equal "Moonlight Sonata", @sheet_music.project_name

    @sheet_music.composition = nil
    assert_nil @sheet_music.project_name
  end

  test "pdf_file_path returns path to file" do
    # This test depends on the storage service being used.
    # For Disk service (default in test), it should return a path.
    # We need to ensure the file is attached and processed (if any processing happens, though here it's just storage)

    path = @sheet_music.pdf_file_path
    assert_not_nil path
    assert File.exist?(path)
  end
end
