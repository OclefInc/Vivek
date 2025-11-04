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
    @lesson = Lesson.new(lesson_params.except(:skill_names, :teacher_name))

    # Find or create teacher by name, or use assignment's default teacher
    if lesson_params[:teacher_name].present?
      teacher = find_or_create_record(Teacher, lesson_params[:teacher_name])
      @lesson.teacher_id = teacher&.id
    elsif @lesson.assignment&.teacher_id.present?
      @lesson.teacher_id = @lesson.assignment.teacher_id
    end

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
    # Find or create teacher by name
    teacher = find_or_create_record(Teacher, lesson_params[:teacher_name])
    @lesson.teacher_id = teacher&.id

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
      if @lesson.update(lesson_params.except(:skill_names, :teacher_name))
        format.html { redirect_to @lesson, notice: "Lesson was successfully updated." }
        format.json { render :show, status: :ok, location: @lesson }
        format.turbo_stream do
          if params[:lesson][:date].present?
            render turbo_stream: [
              turbo_stream.update(
                "lesson_#{@lesson.id}_date",
                partial: "lessons/date_display",
                locals: { lesson: @lesson }
              ),
              turbo_stream.update(
                "assignment_#{@lesson.assignment_id}_date_range",
                partial: "assignments/date_range",
                locals: { assignment: @lesson.assignment }
              )
            ]
          end
        end
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
      params.expect(lesson: [ :date, :lesson_video, :name, :assignment_id, :description, :teacher_name, :video_start_time, :video_end_time, :description_copyrighted, :description_purchase_url, skill_ids: [], skill_names: [] ])
    end

    # Find or create a record by name, skipping validation
    def find_or_create_record(model, name)
      return nil unless name.present?

      record = model.find_by(name: name)
      unless record
        record = model.new(name: name)
        record.save(validate: false)
      end
      record
    end
end
