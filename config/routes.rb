Rails.application.routes.draw do
  namespace :admin do
    resources :account, only: %i[show edit update]
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
  resources :calendar, only: %i[index new create]
  resources :calendar_events, only: %i[index]

  root to: "calendar#index"
end
