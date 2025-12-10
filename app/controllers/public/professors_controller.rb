class Public::ProfessorsController < ApplicationController
  layout "public"
  def index
    @teachers = Teacher.where(show_on_contributors: true)
  end
  def show
    @teacher = Teacher.find(params.expect(:id))
    redirect_to root_path, alert: "This profile is not available." unless @teacher.show_on_contributors
  end
end
