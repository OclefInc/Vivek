# app/controllers/chapters_controller.rb
class ChaptersController < ApplicationController
  before_action :set_lesson
  before_action :set_chapter, only: [ :edit, :update, :destroy ]

  def new
    @chapter = @lesson.chapters.build
    @chapter.start_time = params[:start_time].to_i if params[:start_time].present?
  end

  def create
    @chapter = @lesson.chapters.build(chapter_params)

    if @chapter.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @lesson }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @chapter.update(chapter_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @lesson }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chapter.destroy
    respond_to do |format|
      format.turbo_stream

      format.html { redirect_to @lesson }
    end
  end

  private

    def set_lesson
      @lesson = Lesson.find(params[:lesson_id])
    end

    def set_chapter
      @chapter = @lesson.chapters.find(params[:id])
    end

    def chapter_params
      params.require(:chapter).permit(:name, :start_time, :sort, tutorial_ids: [])
    end
end
