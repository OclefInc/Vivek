class Display::CompositionsController < ApplicationController
  layout "public"
  def index
    @compositions = Composition.all
  end
  def show
    @composition = Composition.find(params.expect(:id))
  end
end
