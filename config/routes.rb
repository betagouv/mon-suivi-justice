require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :convicts
  resources :users
  resources :places
  resources :appointments
  resources :appointment_types
  resources :slots

  get '/select_slot' => 'appointments#select_slot', as: 'select_slot'

  root 'static_pages#home'
end
