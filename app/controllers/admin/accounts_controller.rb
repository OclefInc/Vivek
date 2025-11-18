class Admin::AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def index
    @accounts = User.all

    if params[:query].present?
      query = "%#{params[:query]}%"
      @accounts = @accounts.where("name ILIKE ? OR email ILIKE ?", query, query)
    end

    @accounts = @accounts.order(:name)
  end

  def show
    @account = User.find(params[:id])
  end
end
