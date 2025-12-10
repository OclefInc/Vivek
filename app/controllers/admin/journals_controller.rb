class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_journal, only: %i[ show edit update destroy ]

  # GET /admin/journals
  def index
    @journals = Journal.includes(:composition, :user).order(created_at: :desc)
  end

  # GET /admin/journals/1
  def show
  end

  # GET /admin/journals/new
  def new
    @journal = Journal.new
  end

  # GET /admin/journals/1/edit
  def edit
    if params[:field].present?
      render partial: "form_#{params[:field]}", layout: false
    end
  end

  # POST /admin/journals
  def create
    composition = find_or_create_record(Composition, journal_params[:composition_name])

    @journal = Journal.new(journal_params.except(:composition_name))
    @journal.composition_id = composition&.id
    @journal.user_id = current_user.id

    respond_to do |format|
      if @journal.save
        format.html { redirect_to [  @journal ], notice: "Journal was successfully created." }
        format.json { render :show, status: :created, location: [ @journal ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/journals/1
  def update
    # Find or create student, teacher by name
    composition = find_or_create_record(Composition, journal_params[:composition_name])

    # Update the lesson with other params first
    @journal.assign_attributes(journal_params.except(:composition_name))

    # Update associations using IDs to avoid conflict with string columns
    @journal.composition_id = composition&.id if composition

    respond_to do |format|
      if @journal.save
        format.html { redirect_to [  @journal ] }
        format.json { render :show, status: :ok, location: [  @journal ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/journals/1
  def destroy
    @journal.destroy!

    respond_to do |format|
      format.html { redirect_to journals_url, status: :see_other, notice: "Journal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_journal
      @journal = Journal.find(params[:id])
    end

    def journal_params
      params.require(:journal).permit(:composition_id, :user_id, :description, :summary_video, :video_thumbnail, :composition_name)
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
