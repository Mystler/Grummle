Grummle::Application.routes.draw do
  scope '(:locale)', locale: /en|de/ do
    resources :notes

    get 'about' => 'pages#about'

    get 'signup' => 'users#new'
    post 'signup' => 'users#create'
    get 'edituser' => 'users#edit'
    patch 'edituser' => 'users#update'
    get 'activate/:username/:token', to: 'users#activate', as: 'activate'

    get 'login' => 'sessions#new'
    post 'login' => 'sessions#create'
    get 'logout' => 'sessions#destroy'
  end

  get '/:locale' => 'notes#index'
  root 'notes#index'
end
