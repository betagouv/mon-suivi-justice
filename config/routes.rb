require 'sidekiq/web'

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :organizations
  resources :users
  resources :places
  resources :convicts do
    delete 'archive'
    post 'unarchive'
    post 'self_assign'
    resource :invitation, only: :create, controller: 'convict_invitations'
  end
  resources :appointment_types
  resources :slots
  resource :slots_batch, only: :update

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
  end

  get '/display_time_options' => 'appointments#display_time_options', as: 'display_time_options'
  get '/display_slots' => 'appointments#display_slots', as: 'display_slots'
  get '/display_slot_fields' => 'appointments#display_slot_fields', as: 'display_slot_fields'
  get '/display_places' => 'appointments#display_places', as: 'display_places'
  get '/display_is_cpip' => 'appointments#display_is_cpip', as: 'display_is_cpip'
  get '/display_agendas' => 'appointments#display_agendas', as: 'display_agendas'

  get '/stats' => redirect('https://infogram.com/column-stacked-chart-1h7z2l8www5rg6o?live', status: 302), as: :stats

  scope controller: :bex do
    get :agenda_jap
    get :agenda_spip
  end

  scope controller: :stats do
    get :secret_stats
  end

  scope controller: :home do
    get :home
  end

  resource :steering, only: :show

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
      resources :convicts, only: :show
    end
  end

  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#unprocessable_entity', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
end
