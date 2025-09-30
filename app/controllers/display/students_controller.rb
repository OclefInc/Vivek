class Display::StudentsController < ApplicationController
  layout "public"
  def index
    @students = Student.all
  end
  def show
    @student = Student.find(params.expect(:id))
  end
end
