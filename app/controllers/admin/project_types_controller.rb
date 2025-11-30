module Admin
  class ProjectTypesController < ApplicationController
    before_action :set_project_type, only: %i[ show edit update destroy ]

    def index
      @project_types = ProjectType.all.order(:name)
    end

    def show
    end

    def new
      @project_type = ProjectType.new
    end

    def edit
    end

    def create
      @project_type = ProjectType.new(project_type_params)

      if @project_type.save
        redirect_to admin_project_types_path, notice: "Project type was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @project_type.update(project_type_params)
        redirect_to admin_project_types_path, notice: "Project type was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @project_type.destroy
      redirect_to admin_project_types_path, notice: "Project type was successfully destroyed."
    end

    private
      def set_project_type
        @project_type = ProjectType.find(params[:id])
      end

      def project_type_params
        params.require(:project_type).permit(:name, :description)
      end
  end
end
