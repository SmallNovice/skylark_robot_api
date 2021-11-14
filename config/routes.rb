Rails.application.routes.draw do
  namespace :liaoliao do
    resources :operators do
      post 'receive', on: :collection
    end
  end
end
