class Public::ProjectTypesController < ApplicationController
  layout "public"
  before_action :set_project_type, only: %i[ show edit update destroy ]

  # GET /public/project_types
  def index
    @project_types = ProjectType.includes(assignments: [ lessons: [ :chapters, :rich_text_description, { lesson_video_attachment: :blob } ] ]).order(:name)
  end

  # GET /admin/project_types/1
  def show
  end

  # GET /admin/project_types/new
  def new
    @project_type = ProjectType.new
  end

  # GET /admin/project_types/1/edit
  def edit
  end

  # POST /admin/project_types
  def create
    @project_type = ProjectType.new(project_type_params)

    if @project_type.save
      redirect_to admin_project_types_path, notice: "Project type was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/project_types/1
  def update
    if @project_type.update(project_type_params)
      redirect_to admin_project_types_path, notice: "Project type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/project_types/1
  def destroy
    @project_type.destroy
    redirect_to admin_project_types_path, notice: "Project type was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_type
      @project_type = ProjectType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_type_params
      params.require(:project_type).permit(:name)
    end
end
