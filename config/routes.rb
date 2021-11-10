Rails.application.routes.draw do
  resources :operators, only: [:create]
end
