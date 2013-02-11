UserService::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    mount Doorkeeper::Engine => '/oauth'

    get 'register', :to => 'organizations#new', :as => 'register'
    get 'login', :to => 'sessions#new', :as => 'login'
    get 'logout', :to => 'sessions#destroy', :as => 'logout'

    get 'deactivated_organization', :to => 'static_pages#deactivated_organization', :as => 'deactivated'

    resources :sessions
    resources :password_resets
    resources :organizations do
      resources :users, :only => [:create, :new, :index]
      put 'activate', 'deactivate'
    end

    root :to => 'sessions#new'
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      get 'me', :to => "users#me"
      get 'users/names_for_ids', :to => "users#names_for_ids"
      get 'users/validate_users', :to => "users#validate_users"
      get 'organizations/validate_orgs', :to => "users#validate_orgs"
      resources :organizations, :shallow => true, :only => [:index] do
        resources :users, :shallow => true, :only => [:index]
      end
    end
  end
end
