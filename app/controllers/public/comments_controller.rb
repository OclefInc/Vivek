class Public::CommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :edit, :update, :destroy ]

  def index
    @annotation = params[:annotation_type].constantize.find(params[:annotation_id]) if params[:annotation_type].present? && params[:annotation_id].present?
    @comments = @annotation.comments.includes(:user).order(created_at: :desc) if @annotation
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to comments_path(annotation_type: @comment.annotation.class.name, annotation_id: @comment.annotation.id)
    else
      @annotation = @comment.annotation
      flash.now[:alert] = @comment.errors.full_messages.to_sentence
      render partial: "public/comments/module", locals: { annotation: @annotation, new_comment: @comment }, status: :unprocessable_entity
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    redirect_to root_path, alert: "Not authorized" unless @comment.user == current_user
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.user == current_user
      if @comment.update(comment_params)
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_#{@comment.id}", partial: "public/comments/comment", locals: { comment: @comment }) }
          format.html { redirect_to comments_path(annotation_type: @comment.annotation.class.name, annotation_id: @comment.annotation.id) }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @annotation = @comment.annotation
    if @comment.user == current_user
      @comment.destroy
      redirect_to comments_path(annotation_type: @annotation.class.name, annotation_id: @annotation.id)
    else
      redirect_to root_path, alert: "Not authorized"
    end
  end
  private
    def comment_params
      params.expect(comment: [ :note, :annotation_id, :annotation_type ])
    end
end
