class Admin::SkillCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_skill_category, only: %i[ show ]

  # GET /skills or /skills.json
  def index
    @skill_categories = SkillCategory.includes(:tutorials)

    if params[:query].present?
      query = "%#{params[:query]}%"
      @skill_categories = @skill_categories
        .left_joins(tutorials: :chapters)
        .where("skill_categories.name ILIKE ? OR tutorials.name ILIKE ? OR chapters.name ILIKE ?", query, query, query)
        .distinct
    end

    @skill_categories = @skill_categories.order(:name)
    @teachers = Teacher.all.order(:name)
    @selected_teacher_id = params[:teacher_id]
  end

  # GET /skills/1 or /skills/1.json
  def show
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_skill_category
      @skill_category = SkillCategory.find(params.expect(:id))
    end
end
