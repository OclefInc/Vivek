class TeachersController < ApplicationController
  layout "public"
  def index
    @teachers = Teacher.all
  end
  def show
    @teacher = Teacher.find(params.expect(:id))
  end
end
