# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "public"

  # Skip browser version check for confirmation links (email clients may use older browsers)
  skip_before_action :verify_browser_version, raise: false

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    Rails.logger.info "=== Confirmation show action started ==="
    Rails.logger.info "Params: #{params.inspect}"
    super
    Rails.logger.info "=== Confirmation show action completed ==="
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    Rails.logger.info "=== After confirmation path for #{resource_name} ==="
    super(resource_name, resource)
  end
end
