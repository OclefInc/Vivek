class HomeController < ApplicationController
  # Allow all browsers on public pages
  allow_browser versions: { safari: "11.1", chrome: "80", firefox: "81", edge: "90" }

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
