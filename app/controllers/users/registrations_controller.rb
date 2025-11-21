# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout "public"
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

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

    if resource.provider.present?
      # OAuth users can only update their name and avatar, no password required
      update_params = {
        name: params[:user][:name],
        avatar_crop_x: params[:user][:avatar_crop_x],
        avatar_crop_y: params[:user][:avatar_crop_y],
        avatar_crop_width: params[:user][:avatar_crop_width],
        avatar_crop_height: params[:user][:avatar_crop_height]
      }

      if resource.update(update_params)
        bypass_sign_in resource, scope: :user
        redirect_to edit_user_registration_path, notice: "Profile updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # Regular users go through normal Devise update flow
      super
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
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :name, :password, :password_confirmantion, :current_password, :avatar ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :email, :name, :password, :password_confirmation, :current_password, :avatar, :avatar_crop_x, :avatar_crop_y, :avatar_crop_width, :avatar_crop_height ])
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
