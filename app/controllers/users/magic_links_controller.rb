class Users::MagicLinksController < ApplicationController
  def create
    @user = User.find_by(email: params[:email]&.downcase&.strip)

    if @user && !@user.oauth_user?
      @user.generate_magic_link_token!
      if Rails.env.development?
        magic_link = users_magic_link_url(token: @user.magic_link_token)
        flash[:notice] = "Development Mode: Click here to login: <a href='#{magic_link}' class='underline text-blue-600'>#{magic_link}</a>".html_safe
      else
        @user.send_magic_link
        flash[:notice] = "Check your email for a login link!"
      end
      redirect_to new_user_session_path
    elsif @user && @user.oauth_user?
      flash[:alert] = "Please use #{@user.provider.titleize} to sign in."
      redirect_to new_user_session_path
    else
      # Don't reveal if email exists or not for security
      flash[:notice] = "If that email exists, we sent you a login link."
      redirect_to new_user_session_path
    end
  end

  def show
    @user = User.find_by(magic_link_token: params[:token])

    if @user && @user.magic_link_valid?
      # Clear the token after use
      @user.update(magic_link_token: nil, magic_link_sent_at: nil)

      # Sign in the user
      sign_in(@user)
      flash[:notice] = "Successfully logged in!"
      redirect_to after_sign_in_path_for(@user)
    else
      flash[:alert] = "Invalid or expired login link. Please request a new one."
      redirect_to new_user_session_path
    end
  end
end
