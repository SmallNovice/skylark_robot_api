Rails.application.routes.draw do
  root 'operators#create'
  resources :operators
end
