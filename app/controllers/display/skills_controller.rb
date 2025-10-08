class Display::SkillsController < ApplicationController
  layout "public"
  def index
    @skill_categories = SkillCategory.order(:name)
  end

  def show
    @skill = Skill.find(params.expect(:id))
  end
end
