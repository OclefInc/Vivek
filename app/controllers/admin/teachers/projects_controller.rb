class Admin::Teachers::ProjectsController < ApplicationController
  def index
    @teacher = Teacher.find(params[:teacher_id])
  end
end
