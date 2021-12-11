require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :organizations
  resources :users
  resources :places
  resources :convicts
  resources :appointment_types
  resources :slots
  resources :agendas, only: [:create, :destroy, :update] do
    resources :slot_types, only: :index
  end
  resources :slot_types, only: [:create, :destroy, :update]
  resources :areas_organizations_mappings, only: [:create, :destroy]
  resources :areas_convicts_mappings, only: [:create, :destroy]

  resources :appointments do
    resource :reschedule, only: [:new, :create], controller: 'appointments/reschedules'
    put 'cancel'
    put 'fulfil'
    put 'miss'
    put 'excuse'
  end

  get '/display_slots' => 'appointments#display_slots', as: 'display_slots'
  get '/display_places' => 'appointments#display_places', as: 'display_places'
  get '/display_agendas' => 'appointments#display_agendas', as: 'display_agendas'
  get '/today_appointments' => 'appointments#index_today', as: 'today_appointments'
  get '/stats' => redirect('https://infogram.com/column-stacked-chart-1h7z2l8www5rg6o?live', status: 302), as: :stats

  scope controller: :bex do
    get :agenda_jap
    get :agenda_spip
  end

  scope controller: :static_pages do
    get :landing
    get :comprendre_ma_peine
    get :regles_essentielles
    get :obligations_personnelles
    get :sursis_probatoire
    get :travail_interet_general
    get :suivi_socio_judiciaire
    get :stage
    get :amenagements_de_peine
    get :preparer_mon_rdv
    get :preparer_spip92
    get :preparer_sap_nanterre
    get :ma_reinsertion
    get :donnees_personnelles
  end

  scope controller: :home do
    get :home
  end

  scope controller: :stats do
    get :secret_stats
  end

  scope controller: :steering do
    get :steering
  end

  unauthenticated do
    root 'static_pages#landing'
  end

  authenticated :user do
    root 'home#home', as: :authenticated_root
  end
end
