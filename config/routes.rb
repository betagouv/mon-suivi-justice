Rails.application.routes.draw do
  namespace :admin do
      resources :convicts

      root to: "convicts#index"
    end
  root 'static_pages#home'
end
