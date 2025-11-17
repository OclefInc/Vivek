class Teachers::TutorialsController < ApplicationController
  def index
    @teacher = Teacher.find(params[:teacher_id])
    query = params[:q].to_s.strip

    @tutorials = @teacher.tutorials.order(:name)
    if query.present?
      @tutorials = @tutorials.where("tutorials.name ILIKE ?", "%#{query}%")
    end

    options = @tutorials.map do |tutorial|
      {
        value: tutorial.id,
        text: tutorial.name
      }
    end

    render json: { options: options }
  end
end
