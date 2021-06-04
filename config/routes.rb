Rails.application.routes.draw do
  devise_for :users

  resources :convicts
  resources :users
  resources :places

  root 'static_pages#home'
end
