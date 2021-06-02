Rails.application.routes.draw do
  devise_for :users

  # namespace :admin do
  #   resources :convicts
  #   resources :appointments
  #   resources :users
  #
  #   root to: "convicts#index"
  # end

  root 'static_pages#home'
end
