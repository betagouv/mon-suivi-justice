
require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
      resources :users do
        get '/impersonate' => "users#impersonate"
      end
      resources :convicts
      resources :organizations, except: %i[new create destroy] do
        put '/link_convict_from_linked_orga' => "organizations#link_convict_from_linked_orga"
      end
      resources :departments
      resources :srj_tjs
      resources :srj_spips
      resources :cities
      resources :appointments, except: :index
      resources :places, except: :destroy
      resources :jurisdictions, except: :index
      resources :seeds, only: [:index]
      get '/reset_db' => "seeds#reset_db"
      resources :public_pages, only: [:index]
      resources :import_convicts, only: [:index]
      resources :import_srjs, only: [:index]
      resources :user_alerts
      post '/create_page' => "public_pages#create"
      post '/import_convicts' => "import_convicts#import"
      post '/import_srjs' => "import_srjs#import"
      post '/create_user_alert' => "user_alerts#create"
      resources :headquarters
      resources :place_transferts do
        put '/start_transfert' => "place_transferts#start_transfert"
      end
      resources :divestments, only: %i[index show]
      resources :organization_divestments, only: %i[index show edit update]

      root to: "users#index"
    end

  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :organizations, except: :destroy
  resources :organization_statistics, only: [:index], controller: 'organizations/statistics'

  resources :users do
    collection do
      get :search # used for cpip association to convict in the select
    end
    get :invitation_link
    get :reset_pwd_link
    post :stop_impersonating, on: :collection
    put 'mutate', on: :member
    get :filter, on: :collection
  end

  resource :user do
    resources :appointments, only: [:index], controller: 'users/appointments'
  end

  resources :convicts do
    collection do
      post :search
    end
    delete 'archive'
    post 'unarchive'
    post 'self_assign'
    post 'unassign'
    resource :invitation, only: :create, controller: 'convict_invitations'
  end

  resources :places, except: :destroy do
    patch :archive
  end

  resources :appointment_types
  resources :notification_types_reset, only: :update
  resources :slots
  resource :slots_batch, only: [:new, :create, :update]

  resources :slot_types, only: [:create, :destroy, :update]

  resources :agendas, only: [:create, :update] do
    resources :slot_types, only: :index
    resource :slot_types_batch, only: [:create, :destroy]
  end

  resources :appointments do
    resource :reschedule, only: [:new, :create], controller: 'appointments_reschedules'
    put 'cancel'
    put 'fulfil'
    put 'miss'
    put 'excuse'
    put 'rebook'
  end

  resources :cities do
    collection do
      get :search
    end
    get :services
  end

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
    get :load_cities
  end

  get '/display_time_fields' => 'slots_batches#display_time_fields', as: 'display_time_fields'
  get '/display_interval_fields' => 'slots_batches#display_interval_fields', as: 'display_interval_fields'
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

  resources :security_charter_acceptances, only: %i[new create]

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

  resources :user_user_alerts do
    member do
      put :mark_as_read
    end
  end

  resources :divestments, only: :create
  resources :organization_divestments, only: %i[index edit update]

  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#unprocessable_entity', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
end
