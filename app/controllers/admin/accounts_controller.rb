class Admin::AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def index
    @accounts = User.all
  end

  def show
    @account = User.find(params[:id])
  end
end
