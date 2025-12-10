class Public::SubscriptionsController < ApplicationController
  layout "public"
  before_action :authenticate_user!
  before_action :set_project, except: [ :index ]

  def index
    @assignments = current_user.subscribed_assignments
    @journals = current_user.subscribed_journals
  end

  def create
    @subscription = @project.subscriptions.build(user: current_user)
    if @subscription.save
      redirect_to project_path(@project), notice: "You have successfully subscribed to this project."
    else
      redirect_to project_path(@project), alert: "Unable to subscribe."
    end
  end

  def destroy
    @subscription = @project.subscriptions.find_by(user: current_user)
    if @subscription&.destroy
      redirect_to project_path(@project), notice: "You have successfully unsubscribed from this project."
    else
      redirect_to project_path(@project), alert: "Unable to unsubscribe."
    end
  end

  private

    def set_project
      if params[:project_id]
        @project = Assignment.find(params[:project_id])
      elsif params[:journal_id]
        @project = Journal.find(params[:journal_id])
      end
    end
end
