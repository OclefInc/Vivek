class Admin::Journals::JournalEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_journal
  before_action :set_journal_entry, only: %i[ show edit update destroy ]

  # GET /admin/journals/:journal_id/journal_entries
  def index
    @journal_entries = @journal.journal_entries.order(:sort)
  end

  # GET /admin/journals/:journal_id/journal_entries/1
  def show
  end

  # GET /admin/journals/:journal_id/journal_entries/new
  def new
    @journal_entry = @journal.journal_entries.build
  end

  # GET /admin/journals/:journal_id/journal_entries/1/edit
  def edit
    if params[:field].present?
      render partial: "form_#{params[:field]}", layout: false
    end
  end

  # POST /admin/journals/:journal_id/journal_entries
  def create
    @journal_entry = @journal.journal_entries.build(journal_entry_params)

    respond_to do |format|
      if @journal_entry.save
        format.html { redirect_to [ @journal, @journal_entry ] }
        format.json { render :show, status: :created, location: [ :admin, @journal, @journal_entry ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @journal_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/journals/:journal_id/journal_entries/1
  def update
    respond_to do |format|
      if @journal_entry.update(journal_entry_params)
        format.html { redirect_to [  @journal, @journal_entry ] }
        format.json { render :show, status: :ok, location: [ :admin, @journal, @journal_entry ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @journal_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/journals/:journal_id/journal_entries/1
  def destroy
    @journal_entry.destroy!

    respond_to do |format|
      format.html { redirect_to journal_journal_entries_url(@journal), status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_journal
      @journal = Journal.find(params[:journal_id])
    end

    def set_journal_entry
      @journal_entry = @journal.journal_entries.find(params[:id])
    end

    def journal_entry_params
      params.require(:journal_entry).permit(:name, :date, :description, :entry_video, :video_thumbnail, :video_start_time, :video_end_time)
    end
end
