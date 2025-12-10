class Public::Professors::JournalsController < ApplicationController
  layout "public"

  def index
    @teacher = Teacher.find(params[:professor_id])
    redirect_to root_path, alert: "This profile is not available." unless @teacher.show_on_contributors
    @journals = @teacher.journals.where.not(summary_video_attachment: { id: nil }).joins(:summary_video_attachment)
  end

  def show
    @teacher = Teacher.find(params[:professor_id])
    redirect_to root_path, alert: "This profile is not available." unless @teacher.show_on_contributors
    @journal = Journal.where(id: params[:id]).first
    redirect_to root_path and return unless @journal
  end
end
