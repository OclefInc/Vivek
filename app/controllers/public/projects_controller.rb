class Public::ProjectsController < ApplicationController
  layout "public"
  def index
    @projects = Assignment.all
    if params[:query].present?
      @projects = @projects.joins(:student).where("project_name ILIKE ? OR students.name ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
  end

  def show
    @project = Assignment.where(id: params[:id]).first
    # redirect_to root_path and return unless @project
  end
end
