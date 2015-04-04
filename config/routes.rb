Rails.application.routes.draw do
  devise_for :users, :controllers => { sessions: 'users/sessions', registrations: 'users/registrations', :omniauth_callbacks => 'users/omniauth_callbacks', :passwords => 'users/passwords' }
  
  resources :submissions do
    resources :images
    resources :comments do
      post :like
    end
    resources :uploads do
      get :download
    end
    post :like
    post :dislike
    get :download
  end

  get '/c/(:category/(:subcategory))', to: 'submissions#index', as: 'category'

  get '/home', to: 'home#index'
  root 'home#index'

  get '/p/:username', to: 'application#profile', as: 'profile'

  namespace :api, defaults: { :format => :json } do
    namespace :v1 do
      resources :submissions do
        resources :comments
        resources :images
        resources :uploads
      end
    end
  end
end
