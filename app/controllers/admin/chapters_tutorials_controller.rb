class Admin::ChaptersTutorialsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  def destroy
    @chapters_tutorial = ChaptersTutorial.find(params[:id])
    @chapters_tutorial.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@chapters_tutorial) }
      format.html { redirect_to tutorial_path(@chapters_tutorial.tutorial), notice: "Chapter removed from tutorial." }
    end
  end
end
