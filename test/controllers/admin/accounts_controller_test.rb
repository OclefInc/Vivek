require "test_helper"
require "mocha/minitest"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @account = users(:two)
    sign_in @user
    User.any_instance.stubs(:is_employee?).returns(true)
  end

  test "should get index" do
    get accounts_url
    assert_response :success
    assert_match "Accounts", response.body
  end

  test "should search accounts" do
    get accounts_url(query: @account.name)
    assert_response :success
    assert_match @account.name, response.body
  end

  test "should get show" do
    get account_url(@account)
    assert_response :success
    assert_match @account.name, response.body
  end

  test "should redirect non-employee users" do
    User.any_instance.stubs(:is_employee?).returns(false)
    get accounts_url
    assert_redirected_to root_path
  end

  test "should update employee status" do
    @account.update!(is_employee: false)

    patch update_employee_account_url(@account), params: { user: { is_employee: true } }

    assert_redirected_to account_path(@account)
    assert_equal "Employee status updated.", flash[:notice]
    assert @account.reload.is_employee
  end

  test "should redirect when can not update employee status" do
    User.any_instance.stubs(:update).returns(false)
    @account.update!(is_employee: false)

    patch update_employee_account_url(@account), params: { user: { is_employee: true } }

    assert_redirected_to account_path(@account)
    assert_equal "Unable to update employee status.", flash[:alert]
  end

  test "should not allow removing own employee access" do
    @user.update!(is_employee: true)

    patch update_employee_account_url(@user), params: { user: { is_employee: false } }

    assert_redirected_to account_path(@user)
    assert_equal "You can't remove your own employee access.", flash[:alert]
    assert @user.reload.is_employee
  end
end
