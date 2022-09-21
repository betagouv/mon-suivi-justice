require 'sidekiq/web'

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :organizations
  resources :users do
    get :invitation_link
    get :reset_pwd_link
  end

  resource :user do
    resources :appointments, only: [:index], controller: 'users/appointments'
  end

  resources :convicts do
    delete 'archive'
    post 'unarchive'
    post 'self_assign'
    resource :invitation, only: :create, controller: 'convict_invitations'
  end

  resources :places
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

  get '/display_time_options' => 'appointments#display_time_options', as: 'display_time_options'
  get '/display_slots' => 'appointments#display_slots', as: 'display_slots'
  get '/display_slot_fields' => 'appointments#display_slot_fields', as: 'display_slot_fields'
  get '/display_places' => 'appointments#display_places', as: 'display_places'
  get '/display_is_cpip' => 'appointments#display_is_cpip', as: 'display_is_cpip'
  get '/display_agendas' => 'appointments#display_agendas', as: 'display_agendas'
  get '/display_departments' => 'appointments#display_departments', as: 'display_departments'
  get '/display_submit_button' => 'appointments#display_submit_button', as: 'display_submit_button'
  get '/display_time_fields' => 'slots_batches#display_time_fields', as: 'display_time_fields'

  get '/stats' => redirect('https://infogram.com/column-stacked-chart-1h7z2l8www5rg6o?live', status: 302), as: :stats

  scope controller: :bex do
    get :agenda_jap
    get :agenda_spip
    get :agenda_sap_ddse
  end

  scope controller: :stats do
    get :secret_stats
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
        resource :invitation, only: :update, controller: 'convict_invitations'
      end
    end
  end

  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#unprocessable_entity', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
end
