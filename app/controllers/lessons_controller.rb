class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_lesson, only: %i[ show edit update destroy ]

  # GET /lessons or /lessons.json
  def index
    @lessons = Lesson.all
  end

  # GET /lessons/1 or /lessons/1.json
  def show
    @assignment = @lesson.assignment
  end

  # GET /lessons/new
  def new
    @lesson = Lesson.new(assignment_id: params[:assignment_id])
  end

  # GET /lessons/1/edit
  def edit
    if params[:field].present?
      render partial: "#{params[:field]}_form", layout: false
    end
  end

  # POST /lessons or /lessons.json
  def create
    @lesson = Lesson.new(lesson_params.except(:skill_names))

    # Handle skills - check if skill_names parameter exists (even if empty)
    if params[:lesson] && params[:lesson].key?(:skill_names)
      if params[:lesson][:skill_names].present?
        skill_ids = params[:lesson][:skill_names].reject(&:blank?).map do |skill_name|
          skill = Skill.find_or_create_by(name: skill_name)
          skill.id
        end
        @lesson.skill_ids = skill_ids
      else
        @lesson.skill_ids = []
      end
    end

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson.assignment, notice: "Lesson was successfully created." }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    # Handle skills - check if skill_names parameter exists (even if empty)
    if params[:lesson] && params[:lesson].key?(:skill_names)
      if params[:lesson][:skill_names].present?
        skill_ids = params[:lesson][:skill_names].reject(&:blank?).map do |skill_name|
          skill = Skill.find_or_create_by(name: skill_name)
          skill.id
        end
        @lesson.skill_ids = skill_ids
      else
        @lesson.skill_ids = []
      end
    end

    respond_to do |format|
      if @lesson.update(lesson_params.except(:skill_names))
        format.html { redirect_to @lesson, notice: "Lesson was successfully updated." }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    @lesson.destroy!

    respond_to do |format|
      format.html { redirect_to lessons_path, status: :see_other, notice: "Lesson was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def lesson_params
      params.expect(lesson: [ :lesson_video, :name, :assignment_id, :description, skill_ids: [], skill_names: [] ])
    end
end
