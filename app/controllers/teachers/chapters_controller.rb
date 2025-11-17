class Teachers::ChaptersController < ApplicationController
  def index
    @teacher = Teacher.find(params[:teacher_id])
    query = params[:q].to_s.strip

    # Get all lessons with their chapters
    @lessons = @teacher.lessons.includes(:chapters).order(:name)

    if query.present?
      # Find lessons that match OR have chapters that match
      lesson_ids = @lessons.where("lessons.name ILIKE ?", "%#{query}%").pluck(:id)
      chapter_lesson_ids = Chapter.joins(:lesson)
                                  .where(lesson: { teacher_id: @teacher.id })
                                  .where("chapters.name ILIKE ?", "%#{query}%")
                                  .pluck(:lesson_id)
                                  .uniq

      # Combine both sets of lesson IDs
      all_lesson_ids = (lesson_ids + chapter_lesson_ids).uniq
      @lessons = @lessons.where(id: all_lesson_ids)
    end

    # Build optgroups structure for TomSelect
    optgroups = @lessons.map do |lesson|
      {
        value: lesson.id,
        label: lesson.name
      }
    end

    # Build options with optgroup references
    options = @lessons.flat_map do |lesson|
      chapters = lesson.chapters
      # Only filter chapters if query is present
      if query.present?
        chapters = chapters.where("chapters.name ILIKE ?", "%#{query}%")
      end

      chapters.map do |chapter|
        {
          value: chapter.id,
          text: chapter.name,
          optgroup: lesson.id
        }
      end
    end

    render json: {
      optgroups: optgroups,
      options: options
    }
  end
end
