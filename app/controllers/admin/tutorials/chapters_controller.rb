class Admin::Tutorials::ChaptersController < ApplicationController
  before_action :set_tutorial
  before_action :set_chapter

  def show
    @lesson = @chapter.lesson

    respond_to do |format|
      format.turbo_stream
    end
  end

  private
    def set_tutorial
      @tutorial = Tutorial.find(params[:tutorial_id])
    end

    def set_chapter
      @chapter = Chapter.find(params[:id])
    end
end
