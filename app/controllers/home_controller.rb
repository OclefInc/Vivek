class HomeController < ApplicationController
layout "public"
  # GET /assignments or /assignments.json
  def index
    @projects = Assignment.joins(:summary_video_attachment)
  end
  def about
  end
  def contact
  end
end
