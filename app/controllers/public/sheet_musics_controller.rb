class Public::SheetMusicsController < ApplicationController
  layout "public"
  def index
    @composition = Composition.find(params[:composition_id])
    @sheet_musics = @composition.sheet_musics
  end
  def show
    @sheet_music = SheetMusic.find(params.expect(:id))
  end
end
