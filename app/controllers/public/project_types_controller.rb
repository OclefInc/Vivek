class Public::ProjectTypesController < ApplicationController
  layout "public"

  # GET /public/project_types
  def index
    @project_types = ProjectType.includes(assignments: [ lessons: [ :chapters, :rich_text_description, { lesson_video_attachment: :blob } ] ]).order(:name)
  end

  # GET /public/project_types/1
  def show
    @project_type = ProjectType.find(params[:id])
  end
end
