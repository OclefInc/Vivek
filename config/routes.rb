Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    unlocks: "users/unlocks"
  }

  # Magic link routes
  namespace :users do
    resource :magic_links, only: [ :create ]
    get "magic_links/:token", to: "magic_links#show", as: :magic_link
  end

  devise_scope :user do
    authenticate :user, lambda { |u|u.is_employee? } do
      mount MissionControl::Jobs::Engine, at: "/jobs"
      get "/admin", to: "admin/assignments#index", as: :admin
    end
  end

  scope path: "/admin", module: "admin" do
    resources :accounts
    resources :comments, as: :admin_comments
    resources :skill_categories, only: [ :index, :show ]
    resources :compositions
    resources :teachers do
      resources :chapters, only: [ :index ], controller: "teachers/chapters"
      resources :tutorials, only: [ :index ], controller: "teachers/tutorials"
    end
    resources :sheet_musics
    resources :students
    resources :lessons do
      resources :chapters, only: [ :new, :create, :edit, :update, :destroy ]
    end
    resources :assignments do
      resources :lessons, shallow: true
    end
    resources :project_types
    resources :chapters_tutorials, only: [ :destroy ]

    resources :tutorials do
      resources :chapters, only: [ :show ], controller: "tutorials/chapters"
    end

    # Attachments metadata endpoint
    get "attachments/:sgid/edit_metadata", to: "attachments#edit_metadata"
    post "attachments/update_metadata", to: "attachments#update_metadata"
    post "attachments/update_pages", to: "attachments#update_pages"
  end
  scope path: "/public", module: "public" do
    resources :professors
    resources :students, path: "students", as: "public_students"
    resources :projects do
      resources :episodes, controller: "projects/episodes"
      resource :subscription, only: [ :create, :destroy ], controller: "subscriptions"
    end
    resources :tutorials do
      resources :chapters, only: [ :show ], controller: "tutorials/chapters"
    end
    resources :project_types, path: "project_types", as: "public_project_types"

    resources :comments
    resources :likes, only: [ :create, :destroy ]
    get "subscriptions", to: "subscriptions#index", as: :subscriptions
  end

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
