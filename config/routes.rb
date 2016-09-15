Rails.application.routes.draw do
  post 'login' => 'sessions#create', as: :login
  root to: 'top#index'
end
