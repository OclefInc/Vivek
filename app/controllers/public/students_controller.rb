class Public::StudentsController < ApplicationController
  layout "public"
  def index
    @students = Student.where(show_on_contributors: true)
  end
  def show
    @student = Student.find(params.expect(:id))
    redirect_to root_path, alert: "This profile is not available." unless @student.show_on_contributors
  end
end
