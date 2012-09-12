UserService::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    mount Doorkeeper::Engine => '/oauth'

    get 'register', :to => 'organizations#new', :as => 'register'
    get 'login', :to => 'sessions#new', :as => 'login'
    get 'logout', :to => 'sessions#destroy', :as => 'logout'

    get 'pending_approval', :to => 'static_pages#pending_approval', :as => 'pending'

    resources :sessions
    resources :password_resets
    resources :organizations do
      resources :users, :only => [:create, :new, :index]
      put 'approve', 'reject'
    end

    root :to => 'sessions#new'
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      match 'user', :to => "users#show"
    end
  end
end
