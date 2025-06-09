Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    resources :account, only: %i[show edit update]
    resources :custom_attributes
    resources :users
    resources :resources
    resources :schedule_categories
  end

  resources :bookings do
    collection do
      post :check
    end
  end

  resource :session
  resources :passwords, param: :token
  resources :calendar, only: %i[index new create] do
    collection do
      post :check
    end
  end
  resources :calendar_events, only: %i[index]

  root to: "calendar#index"
end
