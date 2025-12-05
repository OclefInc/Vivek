require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "nav_link_class returns active class when current page matches path" do
    # Mock request to return a specific path
    self.stubs(:request).returns(stub(path: "/dashboard"))
    self.stubs(:current_page?).with("/dashboard").returns(true)

    css_class = nav_link_class([ "/dashboard" ])
    assert_match "bg-sky-200", css_class
    assert_match "border-l-4", css_class
  end

  test "nav_link_class returns active class when current page starts with path" do
    self.stubs(:request).returns(stub(path: "/projects/1"))
    self.stubs(:current_page?).with("/projects").returns(false)

    css_class = nav_link_class([ "/projects" ])
    assert_match "bg-sky-200", css_class
  end

  test "nav_link_class returns active class for admin path" do
    self.stubs(:request).returns(stub(path: "/admin"))

    css_class = nav_link_class([ "/admin" ])
    assert_match "bg-sky-200", css_class
  end

  test "nav_link_class returns active class for admin path with trailing slash" do
    self.stubs(:request).returns(stub(path: "/admin/"))

    css_class = nav_link_class([ "/admin/" ])
    assert_match "bg-sky-200", css_class
  end

  test "nav_link_class returns inactive class when path does not match" do
    self.stubs(:request).returns(stub(path: "/other"))
    self.stubs(:current_page?).with("/dashboard").returns(false)

    css_class = nav_link_class([ "/dashboard" ])
    assert_match "hover:bg-sky-200", css_class
    refute_match "border-l-4", css_class
  end

  test "user_avatar renders attached avatar" do
    user = users(:one)
    # Mock attached? to true
    user.avatar.stubs(:attached?).returns(true)
    user.stubs(:cropped_avatar).returns("avatar.jpg")

    # We can't easily test the image_tag output exactly without more setup,
    # but we can check if it returns an img tag
    assert_match(/<img/, user_avatar(user))
  end

  test "user_avatar renders picture_url when no avatar attached" do
    user = users(:one)
    user.avatar.stubs(:attached?).returns(false)
    user.stubs(:picture_url).returns("http://example.com/pic.jpg")

    assert_match(/src="http:\/\/example.com\/pic.jpg"/, user_avatar(user))
  end

  test "user_avatar renders initials when no avatar or picture_url" do
    user = users(:one)
    user.avatar.stubs(:attached?).returns(false)
    user.stubs(:picture_url).returns(nil)
    user.stubs(:initials).returns("JD")

    output = user_avatar(user)
    assert_match(/JD/, output)
    assert_match(/bg-indigo-500/, output)
  end

  test "project_type_icon returns correct icon for Repertoire" do
    project_type = ProjectType.new(name: "Repertoire")
    assert_match(/<svg/, project_type_icon(project_type))
  end

  test "project_type_icon returns correct icon for Standardized Test Preparation" do
    project_type = ProjectType.new(name: "Standardized Test Preparation")
    assert_match(/<svg/, project_type_icon(project_type))
  end

  test "project_type_icon returns correct icon for Skill Development" do
    project_type = ProjectType.new(name: "Skill Development")
    assert_match(/<svg/, project_type_icon(project_type))
  end

  test "project_type_icon returns correct icon for Music Theory" do
    project_type = ProjectType.new(name: "Music Theory")

    # Mock file existence to test the file reading path
    File.stubs(:exist?).returns(true)
    File.stubs(:read).returns("<svg>content</svg>")

    assert_match(/<svg/, project_type_icon(project_type))
  end

  test "project_type_icon returns fallback for Music Theory when file missing" do
    project_type = ProjectType.new(name: "Music Theory")

    File.stubs(:exist?).returns(false)

    assert_match(/<svg/, project_type_icon(project_type))
  end

  test "project_type_icon returns correct icon for Foundation" do
    project_type = ProjectType.new(name: "Foundation")
    assert_match(/<svg/, project_type_icon(project_type))
  end

  test "project_type_icon returns default icon for unknown type" do
    project_type = ProjectType.new(name: "Unknown")
    assert_match(/<svg/, project_type_icon(project_type))
  end
end
