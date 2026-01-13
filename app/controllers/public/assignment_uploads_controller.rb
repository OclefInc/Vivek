class Public::AssignmentUploadsController < ApplicationController
  layout "public"

  def new
    @assignment = Assignment.find_signed(params[:token])
    if @assignment.nil?
      redirect_to root_path, alert: "Invalid or expired upload link."
      return
    end
    @lesson = @assignment.lessons.new
  end

  def create
    @assignment = Assignment.find_signed(params[:token])
    if @assignment.nil?
      redirect_to root_path, alert: "Invalid or expired upload link."
      return
    end

    @lesson = @assignment.lessons.new(lesson_params)

    # Validation usually requires a name, but lesson model sets default if blank
    # Validation also requires lesson_video usually, but it was commented out in the model file I read?
    # Let's check Lesson model again.
    # validates_presence_of :lesson_video is commented out.

    if @lesson.save
      redirect_to new_assignment_upload_path(params[:token]), notice: "Video uploaded successfully! You can upload another one."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def lesson_params
      params.require(:lesson).permit(:lesson_video, :name)
    end
end
