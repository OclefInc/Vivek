class Admin::AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_account, only: [ :show, :update_employee ]

  def index
    @accounts = User.all

    if params[:query].present?
      query = "%#{params[:query]}%"
      @accounts = @accounts.where("name ILIKE ? OR email ILIKE ?", query, query)
    end

    @accounts = @accounts.order(:name)
  end

  def show
  end

  def update_employee
    requested_employee = ActiveModel::Type::Boolean.new.cast(employee_params[:is_employee])

    if @account == current_user && !requested_employee
      redirect_to account_path(@account), alert: "You can't remove your own employee access."
      return
    end

    if @account.update(is_employee: requested_employee)
      redirect_to account_path(@account), notice: "Employee status updated."
    else
      redirect_to account_path(@account), alert: "Unable to update employee status."
    end
  end

  private

    def set_account
      @account = User.find(params[:id])
    end

    def employee_params
      params.expect(user: [ :is_employee ])
    end
end
