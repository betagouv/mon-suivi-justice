Rails.application.routes.draw do
  devise_for :users

  resources :convicts
  resources :users
  resources :places
  resources :appointments
  resources :slots

  get '/appointment/:convict_id/:place_id', to: 'appointments#new_first',
                                            as: 'new_first_appointment'

  get '/select_slot' => 'appointments#select_slot', as: 'select_slot'

  root 'static_pages#home'
end
