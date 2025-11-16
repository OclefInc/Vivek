Rails.application.routes.draw do
  namespace :display do
    resources :sheet_musics
    resources :skills
    resources :compositions
    resources :teachers
    resources :students
  end
  resources :sheet_musics
  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    # omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    unlocks: "users/unlocks"
  }
  devise_scope :user do
    authenticate :user, lambda { |u|u.is_employee? } do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end
  end
  resources :accounts
  resources :skills
  resources :compositions
  resources :teachers
  resources :students
  resources :lessons do
    resources :chapters, only: [ :new, :create, :edit, :update, :destroy ]
  end
  resources :assignments
  resources :projects do
    resources :episodes
  end

  resources :comments

  resources :chapters_tutorials, only: [ :destroy ]

  resources :tutorials do
    resources :chapters, only: [ :show ], controller: "tutorials/chapters"
  end

  # Attachments metadata endpoint
  get "attachments/:sgid/edit_metadata", to: "attachments#edit_metadata"
  post "attachments/update_metadata", to: "attachments#update_metadata"
  post "attachments/update_pages", to: "attachments#update_pages"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  get "/about", to: "home#about"
  get "/contact", to: "home#contact"
  root to: "home#index"
end
