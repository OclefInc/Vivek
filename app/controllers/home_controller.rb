class HomeController < ApplicationController
  # Allow all browsers on public pages
  allow_browser versions: { safari: "11.1", chrome: "80", firefox: "81", edge: "90" }

  layout "public"
  # GET /assignments or /assignments.json
  def index
    @projects = Assignment.includes(lessons: [ :chapters, :rich_text_description, { lesson_video_attachment: :blob } ]).all
    @in_progress_projects = @projects.reject(&:complete?)
    @completed_projects = @projects.select(&:complete?)
  end
  def about
  end
  def contact
  end
  def contributors
    @students = Student.where(show_on_contributors: true).order(:name)
    @teachers = Teacher.where(show_on_contributors: true).order(:name)
  end
end
