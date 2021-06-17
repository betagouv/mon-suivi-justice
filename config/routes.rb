require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'

  resources :convicts
  resources :users
  resources :places
  resources :appointments
  resources :slots

  get '/select_slot' => 'appointments#select_slot', as: 'select_slot'

  root 'static_pages#home'
end
