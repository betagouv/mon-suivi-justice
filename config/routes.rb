Rails.application.routes.draw do
  devise_for :users

  resources :convicts
  resources :users

  # namespace :admin do
  #   resources :appointments
  #
  #   root to: "convicts#index"
  # end

  root 'static_pages#home'
end
