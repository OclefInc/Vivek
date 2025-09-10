class CommentsController < ApplicationController
  before_action :authenticate_user!
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
  private
  def comment_params
      params.expect(comment: [ :note, :annotation_id, :annotation_type ])
    end
end
