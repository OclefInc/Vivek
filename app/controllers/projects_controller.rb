class ProjectsController < ApplicationController
  layout "public"
  def index
    @projects=Assignment.all
  end

  def show
    @project=Assignment.where(id:params[:id]).first
    # redirect_to root_path and return unless @project
  end
end
