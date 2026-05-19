class Public::ProfessorsController < ApplicationController
  layout "public"
  def index
    @teachers = Teacher.where(show_on_contributors: true)
  end
  def show
    @teacher = Teacher.find_by(id: params[:id])
    redirect_to root_path, alert: "This profile is not available." unless @teacher && @teacher.show_on_contributors
  end
end
