class Admin::Teachers::JournalsController < ApplicationController
  def index
    @teacher = Teacher.find(params[:teacher_id])
  end
end
