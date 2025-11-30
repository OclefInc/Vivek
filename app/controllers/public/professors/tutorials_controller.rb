class Public::Professors::TutorialsController < ApplicationController
  layout "public"

  def index
  end

  def show
    @tutorial = Tutorial.where(id: params[:id]).first
    redirect_to root_path and return unless @tutorial
  end
end
