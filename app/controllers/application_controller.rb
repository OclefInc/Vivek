class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  def authorize_user
    if current_user.is_employee?
      nil
    else
      redirect_to root_path
    end
  end
end
