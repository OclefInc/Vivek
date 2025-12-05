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
end
