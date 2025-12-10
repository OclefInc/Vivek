class Admin::TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_teacher, only: %i[ show edit update destroy toggle_visibility ]

  # GET /teachers or /teachers.json
  def index
    @teachers = Teacher.all

    if params[:query].present?
      query = "%#{params[:query]}%"
      @teachers = @teachers.where("name ILIKE ?", query)
    end

    @teachers = @teachers.order(:name)
  end

  # GET /teachers/1 or /teachers/1.json
  def show
  end

  # GET /teachers/new
  def new
    @teacher = Teacher.new
  end

  # GET /teachers/1/edit
  def edit
    if params[:field].present?
      render partial: "form_#{params[:field]}", layout: false
    end
  end

  # POST /teachers or /teachers.json
  def create
    @teacher = Teacher.new(teacher_params)

    respond_to do |format|
      if @teacher.save
        format.html { redirect_to @teacher, notice: "Teacher was successfully created." }
        format.json { render :show, status: :created, location: @teacher }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /teachers/create_from_user
  def create_from_user
    if current_user.teacher.present?
      redirect_to current_user.teacher, notice: "You already have a teacher profile!"
      return
    end

    @teacher = Teacher.new(
      user_id: current_user.id,
      name: current_user.name || current_user.email.split("@").first
    )

    if @teacher.save
      redirect_to @teacher, notice: "Your teacher profile was successfully created!"
    else
      redirect_to teachers_path, alert: "Could not create teacher profile: #{@teacher.errors.full_messages.join(', ')}"
    end
  end

  # PATCH/PUT /teachers/1 or /teachers/1.json
  def update
    respond_to do |format|
      if @teacher.update(teacher_params)
        format.html { redirect_to @teacher }
        format.json { render :show, status: :ok, location: @teacher }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teachers/1 or /teachers/1.json
  def destroy
    @teacher.destroy!

    respond_to do |format|
      format.html { redirect_to teachers_path, status: :see_other, notice: "Teacher was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # PATCH /teachers/1/toggle_visibility
  def toggle_visibility
    @teacher.update!(show_on_contributors: !@teacher.show_on_contributors)
    respond_to do |format|
      format.html { redirect_to @teacher, notice: "Profile visibility updated." }
      format.turbo_stream
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teacher
      @teacher = Teacher.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def teacher_params
      params.expect(teacher: [ :profile_picture, :name, :city, :bio, :user_id, :avatar_crop_x, :avatar_crop_y, :avatar_crop_width, :avatar_crop_height ])
    end
end
