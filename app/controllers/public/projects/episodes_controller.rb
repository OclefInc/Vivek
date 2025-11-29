class Public::Projects::EpisodesController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update ]
  before_action :authorize_user, only: [ :edit, :update ]

  layout "public"
  def index
  end
  def show
    @episode = Lesson. where(id: params[:id]).first
    redirect_to root_path and return unless @episode
  end
  def edit
  end

  def update
    respond_to do |format|
      if @episode.update(episode_params)
        format.html { redirect_to project_episode_path(@episode.project, @episode), notice: "Episode was successfully updated." }

      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private
    def authorize_user
      @episode = Lesson. where(id: params[:id]).first
      redirect_to root_path and return unless @episode
      if current_user == @episode.assignment.teacher.user
        nil
      else
        redirect_to root_path
      end
    end

    def episode_params
      params.expect(lesson: [ :teacher_journal, :student_journal ])
      end
end
