class CommentsController < ApplicationController
  before_action :authenticate_user!
  def index
    redirect_to_root_path unless current_user.is_employee?
    @comments = Comment.order(created_at: :desc)
  end
  def show
    redirect_to_root_path unless current_user.is_employee?
    @comment = Comment.find(params[:id])
  end
  
  def create
    @comment = Comment.new(comment_params)
    @comment.user=current_user
    @comment.save
    if @comment.annotation_type=="Lesson"
      @episode=@comment.annotation
      @project=@episode.assignment
      redirect_to project_episode_path(@project, @episode)
    else
      redirect_to @comment.annotation
    end
  end
  def destroy
    @comment = Comment.find(params[:id])
    @comment.unpublish(current_user.id)
    respond_to do |format|
      format.html { redirect_to comments_path, status: :see_other, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  private
  def comment_params
      params.expect(comment: [ :note, :annotation_id, :annotation_type ])
    end
    
end
