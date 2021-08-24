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

  resources :appointments do
    put 'cancel'
    put 'fulfil'
    put 'miss'
  end

  get '/display_slots' => 'appointments#display_slots', as: 'display_slots'
  get '/display_places' => 'appointments#display_places', as: 'display_places'
  get '/display_agendas' => 'appointments#display_agendas', as: 'display_agendas'

  get '/today_appointments' => 'appointments#index_today', as: 'today_appointments'

  scope controller: :bex do
    get :agenda_jap
    get :agenda_spip
  end

  scope controller: :static_pages do
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
    root 'static_pages#landing'
  end

  authenticated :user do
    root 'home#home', as: :authenticated_root
  end
end
