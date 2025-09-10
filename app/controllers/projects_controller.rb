class ProjectsController < ApplicationController
  def index
  end

  def show
    @project=Assignment.where(id:params[:id]).first
    # redirect_to root_path and return unless @project
  end
end
