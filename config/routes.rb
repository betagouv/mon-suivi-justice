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
  end

  get '/display_slots' => 'appointments#display_slots', as: 'display_slots'
  get '/display_places' => 'appointments#display_places', as: 'display_places'
  get '/display_agendas' => 'appointments#display_agendas', as: 'display_agendas'

  get '/today_appointments' => 'appointments#index_today', as: 'today_appointments'

  root 'static_pages#home'

  scope controller: :bex do
    get :agenda_jap
    get :agenda_spip
  end

  scope controller: :static_pages do
    get :home
    get :comprendre_mes_mesures
    get :sursis_probatoire
    get :travail_interet_general
  end
end
