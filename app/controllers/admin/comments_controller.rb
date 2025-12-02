class Admin::CommentsController < ApplicationController
  before_action :authenticate_user!
  def index
    redirect_to root_path unless current_user.is_employee?
    @comments = Comment.includes(:user).preload(:annotation)

    if params[:query].present?
      query = "%#{params[:query]}%"
      @comments = @comments.joins(:user).left_joins(:rich_text_note).where("users.name ILIKE ? OR action_text_rich_texts.body ILIKE ?", query, query)
    end

    @comments = @comments.order(created_at: :desc)
  end
  def show
    redirect_to root_path unless current_user.is_employee?
    @comment = Comment.find(params[:id])
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.toggle_publish(current_user.id)
    respond_to do |format|
      format.html { redirect_to [ :admin, @comment ], status: :see_other, notice: "Comment was successfully #{ @comment.published_status}." }
      format.json { head :no_content }
    end
  end
end
