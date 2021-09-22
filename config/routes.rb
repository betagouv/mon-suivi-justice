require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :convicts
  resources :users
  resources :places
  resources :appointment_types
  resources :slots
  resources :agendas, only: [:create, :destroy, :update]
  resources :slot_types, only: [:create, :destroy, :update]

  resources :appointments do
    put 'cancel'
    put 'fulfil'
    put 'miss'
  end

  get '/display_slots' => 'appointments#display_slots', as: 'display_slots'
  get '/display_places' => 'appointments#display_places', as: 'display_places'
  get '/display_agendas' => 'appointments#display_agendas', as: 'display_agendas'
  get '/today_appointments' => 'appointments#index_today', as: 'today_appointments'
  get "/stats" => redirect("https://infogram.com/column-stacked-chart-1h7z2l8www5rg6o?live"), as: :stats

  scope controller: :bex do
    get :agenda_jap
    get :agenda_spip
  end

  scope controller: :temporary_landings do
    get :landing
  end

  scope controller: :static_pages do
    get :secret
    get :landing
    get :comprendre_mes_mesures
    get :sursis_probatoire
    get :travail_interet_general
    get :suivi_socio_judiciaire
    get :stage
    get :amenagements_de_peine
  end

  scope controller: :home do
    get :home
  end

  unauthenticated do
    root 'temporary_landings#landing'
  end

  authenticated :user do
    root 'home#home', as: :authenticated_root
  end
end
