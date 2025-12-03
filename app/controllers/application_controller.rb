class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :store_return_to_location

  def authorize_user
    if current_user.is_employee?
      nil
    else
      redirect_to root_path
    end
  end

  layout :layout_by_resource

  private

    def store_return_to_location
      if params[:return_to].present?
        store_location_for(:user, params[:return_to])
      end
    end

    def layout_by_resource
      if devise_controller?
        "public"
      else
        "application"
      end
    end
end
