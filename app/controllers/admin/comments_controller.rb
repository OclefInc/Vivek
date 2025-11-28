class Admin::CommentsController < ApplicationController
  before_action :authenticate_user!
  def index
    redirect_to_root_path unless current_user.is_employee?
    @comments = Comment.includes(:user, :annotation)

    if params[:query].present?
      query = "%#{params[:query]}%"
      @comments = @comments.joins(:user).where("users.name ILIKE ? OR comments.body ILIKE ?", query, query)
    end

    @comments = @comments.order(created_at: :desc)
  end
  def show
    redirect_to_root_path unless current_user.is_employee?
    @comment = Comment.find(params[:id])
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
      redirect_back fallback_location: root_path, notice: "Comment deleted."
    else
      @comment.toggle_publish(current_user.id)
      respond_to do |format|
        format.html { redirect_to [ :admin, @comment ], status: :see_other, notice: "Comment was successfully #{ @comment.published_status}." }
        format.json { head :no_content }
      end
    end
  end
  private
    def comment_params
      params.expect(comment: [ :note, :annotation_id, :annotation_type ])
    end
end
