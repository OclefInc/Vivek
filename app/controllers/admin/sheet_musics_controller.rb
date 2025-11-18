class Admin::SheetMusicsController < ApplicationController
  before_action :set_sheet_music, only: %i[ show edit update destroy ]

  # GET /sheet_musics or /sheet_musics.json
  def index
    @composition = Composition.find(params[:composition_id])
    @sheet_musics = @composition.sheet_musics
  end

  # GET /sheet_musics/1 or /sheet_musics/1.json
  def show
  end

  # GET /sheet_musics/new
  def new
    @sheet_music = SheetMusic.new(composition_id: params[:composition_id])
  end

  # GET /sheet_musics/1/edit
  def edit
  end

  # POST /sheet_musics or /sheet_musics.json
  def create
    @sheet_music = SheetMusic.new(sheet_music_params)

    respond_to do |format|
      if @sheet_music.save
        format.html { redirect_to @sheet_music, notice: "Sheet music was successfully created." }
        format.json { render :show, status: :created, location: @sheet_music }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sheet_music.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sheet_musics/1 or /sheet_musics/1.json
  def update
    respond_to do |format|
      if @sheet_music.update(sheet_music_params)
        format.html { redirect_to @sheet_music, notice: "Sheet music was successfully updated." }
        format.json { render :show, status: :ok, location: @sheet_music }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sheet_music.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sheet_musics/1 or /sheet_musics/1.json
  def destroy
    @sheet_music.destroy!

    respond_to do |format|
      format.html { redirect_to sheet_musics_path, status: :see_other, notice: "Sheet music was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sheet_music
      @sheet_music = SheetMusic.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sheet_music_params
      params.expect(sheet_music: [ :composition_id, :pdf_file ])
    end
end
