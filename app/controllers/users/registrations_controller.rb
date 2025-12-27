# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    build_resource(sign_up_params)

    # Don't require password for regular users
    unless resource.oauth_user?
      resource.password = Devise.friendly_token[0, 20]
      resource.password_confirmation = resource.password
      # Skip default confirmation email since we use magic links
      resource.skip_confirmation_notification!
    end

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        # Send magic link instead of signing in directly
        if Rails.env.development?
          resource.generate_magic_link_token!
          magic_link = users_magic_link_url(token: resource.magic_link_token)
          flash[:notice] = "Development Mode: Click here to login: <a href='#{magic_link}' class='underline text-blue-600'>#{magic_link}</a>".html_safe
        else
          resource.send_magic_link
          flash[:notice] = "Welcome! Check your email for a magic link to login."
        end
        respond_with resource, location: new_user_session_path
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    # Handle avatar attachment for all users before update
    if params[:user][:avatar].present?
      resource.avatar.attach(params[:user][:avatar])
    end

    # Allow updating without password for everyone
    # We use account_update_params which filters allowed keys
    if resource.update(account_update_params)
      bypass_sign_in resource, scope: :user
      redirect_to edit_user_registration_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :name, :avatar ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :avatar, :avatar_crop_x, :avatar_crop_y, :avatar_crop_width, :avatar_crop_height ])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
