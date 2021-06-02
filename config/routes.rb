Rails.application.routes.draw do
  devise_for :users

  resources :convicts

  # namespace :admin do
  #   resources :appointments
  #   resources :users
  #
  #   root to: "convicts#index"
  # end

  root 'static_pages#home'
end
