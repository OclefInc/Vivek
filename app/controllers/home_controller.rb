class HomeController < ApplicationController
  layout "public"
  # GET /assignments or /assignments.json
  def index
    @projects = Assignment.joins(:summary_video_attachment)

    respond_to do |format|
      format.html
      format.any { render html: "", layout: false }
    end
  end
  def about
  end
  def contact
  end
end
