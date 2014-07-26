Grummle::Application.routes.draw do
  scope '(:locale)', locale: /en|de/ do
    resources :notes

    get 'about' => 'pages#about'

    get 'signup' => 'users#new'
    post 'signup' => 'users#create'
    get 'edituser' => 'users#edit'
    patch 'edituser' => 'users#update'
    get 'activate/:username/:token', to: 'users#activate', as: 'activate'
    get 'resend_activation/:username', to: 'users#resend_activation', as: 'resend_activation'
    get 'forgot_password' => 'users#forgot_password'
    post 'reset_password' => 'users#reset_password'
    get 'new_password/:username/:token', to: 'users#new_password', as: 'new_password'
    patch 'update_password/:username/:token', to: 'users#update_password', as: 'update_password'

    get 'login' => 'sessions#new'
    post 'login' => 'sessions#create'
    get 'logout' => 'sessions#destroy'
  end

  get '/:locale' => 'notes#index'
  root 'notes#index'
end
