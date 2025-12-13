require "test_helper"

class NilSafetyTest < ActiveSupport::TestCase
  test "lessons handle nil teacher gracefully" do
    lesson = lessons(:one)
    lesson.update(teacher: nil)

    assert_nothing_raised do
      lesson.teacher&.name
      lesson.teacher&.display_avatar
      lesson.teacher&.initials
    end
  end

  test "episodes handle nil teacher gracefully" do
    episode = lessons(:one)
    episode.update(teacher: nil)

    assert_nothing_raised do
      episode.teacher&.name
      episode.teacher&.display_avatar
    end
  end

  test "journals handle nil user teacher gracefully" do
    user = users(:two)
    journal = Journal.create!(
      composition: compositions(:one),
      user: user
    )

    # User has no teacher
    assert_nil user.teacher

    assert_nothing_raised do
      user.teacher&.increment!(:journals_count)
    end
  end

  test "teachers handle nil user gracefully" do
    teacher = Teacher.create!(name: "No User Teacher", user: nil)

    assert_nothing_raised do
      teacher.journals
      teacher.user&.name
    end

    # journals should return nil or empty when no user
    assert teacher.journals.nil? || teacher.journals.empty?
  end
end
