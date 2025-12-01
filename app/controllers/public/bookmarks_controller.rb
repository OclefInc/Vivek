module Public
  class BookmarksController < ApplicationController
    layout "public"
    before_action :authenticate_user!, except: [ :button ]

    def index
      @bookmarks = current_user.bookmarks.includes(:bookmarkable).order(created_at: :desc)
    end

    def button
      @bookmarkable = GlobalID::Locator.locate params[:bookmarkable_sgid]
      @bookmarkable ||= params[:bookmarkable_type].constantize.find(params[:bookmarkable_id])
      render partial: "public/bookmarks/button", locals: { bookmarkable: @bookmarkable }
    end

    def create
      @bookmark = current_user.bookmarks.new(bookmark_params)

      if @bookmark.save
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path, notice: "Bookmarked successfully." }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path, alert: "Unable to bookmark." }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("bookmark_button", partial: "public/bookmarks/button", locals: { bookmarkable: @bookmark.bookmarkable }) }
        end
      end
    end

    def destroy
      @bookmark = current_user.bookmarks.find(params[:id])
      bookmarkable = @bookmark.bookmarkable
      @bookmark.destroy

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "Bookmark removed." }
        format.turbo_stream
      end
    end

    private

      def bookmark_params
        params.require(:bookmark).permit(:bookmarkable_id, :bookmarkable_type)
      end
  end
end
