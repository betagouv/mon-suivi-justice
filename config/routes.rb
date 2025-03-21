require 'sidekiq/web'

Rails.application.routes.draw do
  get 'stop_sms', to: 'unsubscribe#stop_sms'
  post 'stop_sms/refuse_phone', to: 'unsubscribe#refuse_phone', as: 'refuse_phone'
  namespace :admin do
      resources :users do
        get '/impersonate' => "users#impersonate"
        get '/unlock' => "users#unlock"
      end
      resources :convicts do
        collection do
          get :merge_form
          get :merge_preview
          post :merge_execute
        end
      end
      resources :appointments, except: :index
      resources :organizations, except: %i[new create destroy] do
        put '/link_convict_from_linked_orga' => "organizations#link_convict_from_linked_orga"
      end
      resources :srj_tjs
      resources :srj_spips
      resources :cities
      resources :places, except: :destroy
      resources :seeds, only: [:index]
      get '/reset_db' => "seeds#reset_db"
      resources :import_convicts, only: [:index]
      resources :import_srjs, only: [:index]
      resources :user_alerts
      post '/import_convicts' => "import_convicts#import"
      post '/import_srjs' => "import_srjs#import"
      post '/create_user_alert' => "user_alerts#create"
      resources :headquarters
      resources :place_transferts
      resources :divestments, only: %i[index show]
      resources :organization_divestments, only: %i[show edit update]

      root to: "users#index"
    end

  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :organizations, except: %i[show destroy]
  resources :organization_statistics, only: [:index], controller: 'organizations/statistics'

  resources :users, except: %i[new create] do
    collection do
      get :search # used for cpip association to convict in the select
    end
    get :invitation_link
    get :reset_pwd_link
    post :stop_impersonating, on: :collection
    put 'mutate', on: :member
    get :filter, on: :collection
  end

  resources :convicts do
    delete 'archive'
    post 'unarchive'
    post 'self_assign'
    post 'unassign'
    member do
      patch :accept_phone
    end
  end

  resources :places, except: %i[show destroy] do
    patch :archive
  end

  resources :appointment_types, except: %i[new create show destroy]
  resources :notification_types_reset, only: :update
  resources :slots, except: %i[new create show destroy]
  resource :slots_batch, only: [:new, :create, :update]

  resources :slot_types, only: [:create, :destroy, :update]

  resources :agendas, only: [:create, :update] do
    resources :slot_types, only: :index
    resource :slot_types_batch, only: [:create, :destroy]
  end

  resources :appointments, except: %i[edit update destroy] do
    resource :reschedule, only: [:new, :create], controller: 'appointments_reschedules'
    put 'cancel'
    put 'fulfil'
    put 'miss'
    put 'excuse'
    put 'rebook'
  end

  resources :cities, only: [] do
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

  get '/convict_interface', to: 'public_pages#convict_interface'

  authenticated :user do
    root 'home#home', as: :authenticated_root
  end

  resources :user_user_alerts, only: [] do
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
