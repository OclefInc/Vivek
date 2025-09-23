Rails.configuration.to_prepare do
  SortableController.class_eval do
    protect_from_forgery with: :null_session
  end
end
