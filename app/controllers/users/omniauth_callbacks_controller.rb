# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  layout "public"
  skip_before_action :verify_authenticity_token, only: [ :google_oauth2, :apple, :facebook ]
  skip_forgery_protection only: [ :apple ]

  def google_oauth2
    handle_auth "Google"
  end

  def apple
    handle_auth "Apple"
  end

  def facebook
    handle_auth "Facebook"
  end

  def failure
    flash[:alert] = "Authentication failed. Please try again."
    redirect_to new_user_session_path
  end

  private

    def handle_auth(kind)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        session["devise.#{kind.downcase}_data"] = request.env["omniauth.auth"].except("extra")
        flash[:alert] = "There was a problem signing you in through #{kind}. Please try again."
        redirect_to new_user_registration_url
      end
    end
end
