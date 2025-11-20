# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  layout "public"

  # Skip CSRF verification for password reset to handle same_site: none session issues
  skip_before_action :verify_authenticity_token, only: [ :update, :create ]
  protect_from_forgery with: :null_session, only: [ :update ]

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
