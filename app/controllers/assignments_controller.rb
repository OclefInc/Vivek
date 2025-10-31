class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_assignment, only: %i[ show edit update destroy ]

  # GET /assignments or /assignments.json
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1 or /assignments/1.json
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
    if params[:field].present?
      render partial: "#{params[:field]}_form", layout: false
    end
  end

  # POST /assignments or /assignments.json
  def create
    # Find or create student, teacher, and composition by name
    student = find_or_create_record(Student, assignment_params[:student_name])
    teacher = find_or_create_record(Teacher, assignment_params[:teacher_name])
    composition = find_or_create_record(Composition, assignment_params[:composition_name])

    # Create assignment with the associated records
    @assignment = Assignment.new(assignment_params.except(:student_name, :teacher_name, :composition_name))
    @assignment.student_id = student&.id
    @assignment.teacher_id = teacher&.id
    @assignment.composition_id = composition&.id

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: "Assignment was successfully created." }
        format.json { render :show, status: :created, location: @assignment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1 or /assignments/1.json
  def update
    # Find or create student, teacher, and composition by name
    student = find_or_create_record(Student, assignment_params[:student_name])
    teacher = find_or_create_record(Teacher, assignment_params[:teacher_name])
    composition = find_or_create_record(Composition, assignment_params[:composition_name])

    # Update associations using IDs to avoid conflict with string columns
    @assignment.student_id = student&.id
    @assignment.teacher_id = teacher&.id
    @assignment.composition_id = composition&.id

    respond_to do |format|
      if @assignment.update(assignment_params.except(:student_name, :teacher_name, :composition_name))
        format.html { redirect_to @assignment, notice: "Assignment was successfully updated." }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1 or /assignments/1.json
  def destroy
    @assignment.destroy!

    respond_to do |format|
      format.html { redirect_to assignments_path, status: :see_other, notice: "Assignment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def assignment_params
      params.require(:assignment).permit(:student_id, :teacher_id, :composition_id, :student_name, :teacher_name, :composition_name, :summary_video, :description)
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
