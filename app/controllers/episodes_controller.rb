class EpisodesController < ApplicationController
  layout "public"
  def index
  end

  def show
    @episode=Lesson.where(id:params[:id]).first
    redirect_to root_path and return unless @episode 
  end
end
