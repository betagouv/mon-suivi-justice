
require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
      resources :users do
        get '/impersonate' => "users#impersonate"
      end
      resources :convicts
      resources :organizations
      resources :departments
      resources :slots
      resources :places, except: :index
      resources :jurisdictions, except: :index
      if Rails.env.development?
        resources :seeds, only: [:index]
        get '/reset_db' => "seeds#reset_db"
      end
      resources :public_pages, only: [:index]
      resources :import_convicts, only: [:index]
      post '/create_page' => "public_pages#create"
      post '/import_convicts' => "import_convicts#import"

      root to: "users#index"
    end
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :organizations
  resources :users do
    get :invitation_link
    get :reset_pwd_link
    post :stop_impersonating, on: :collection
  end

  resource :user do
    resources :appointments, only: [:index], controller: 'users/appointments'
    resources :user_notifications, only: [:index], controller: 'users/notifications'
  end

  resources :convicts do
    delete 'archive'
    post 'unarchive'
    post 'self_assign'
    resource :invitation, only: :create, controller: 'convict_invitations'
  end

  resources :places do
    patch :archive
  end

  resources :appointment_types
  resources :notification_types_reset, only: :update
  resources :slots
  resource :slots_batch, only: [:new, :create, :update]

  resources :slot_types, only: [:create, :destroy, :update]

  resources :agendas, only: [:create, :destroy, :update] do
    resources :slot_types, only: :index
    resource :slot_types_batch, only: [:create, :destroy]
  end

  resources :areas_organizations_mappings, only: [:create, :destroy]
  resources :areas_convicts_mappings, only: [:create, :destroy]

  resources :appointments do
    resource :reschedule, only: [:new, :create], controller: 'appointments_reschedules'
    put 'cancel'
    put 'fulfil'
    put 'miss'
    put 'excuse'
    put 'rebook'
    put 'prepare'
  end

  resources :appointments_waiting_lines, only: :index

  scope controller: :appointments_bookings do
    get :load_places
    get :load_prosecutor
    get :load_is_cpip
    get :load_agendas
    get :load_departments
    get :load_time_options
    get :load_slots
    get :load_slot_fields
    get :load_submit_button
  end

  get '/display_time_fields' => 'slots_batches#display_time_fields', as: 'display_time_fields'
  get '/stats' => redirect('https://infogram.com/column-stacked-chart-1h7z2l8www5rg6o?live', status: 302), as: :stats

  scope controller: :bex do
    match :agenda_jap, via: [:get, :post], defaults: { appointment_type: 'Sortie d\'audience SAP', }
    get :agenda_spip, defaults: { appointment_type: 'Sortie d\'audience SPIP' }
    get :agenda_sap_ddse, defaults: { appointment_type: 'SAP DDSE' }
    put :appointment_extra_field
  end

  scope controller: :home do
    get :home
  end

  resource :steering, only: :show

  get '/steering_user_app' => 'steerings#user_app_stats', as: 'steering_user_app'
  get '/steering_convict_app' => 'steerings#convict_app_stats', as: 'steering_convict_app'
  get '/steering_sda' => 'steerings#sda_stats', as: 'steering_sda'

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new"
    end
  end

  authenticated :user do
    root 'home#home', as: :authenticated_root
  end

  namespace :api, defaults: {format: "json"} do
    namespace :v1 do
      resources :convicts, only: :show do
        get 'cpip'
        resource :invitation, only: :update, controller: 'convict_invitations'
      end
    end
  end

  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#unprocessable_entity', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
end
