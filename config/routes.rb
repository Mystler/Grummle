Grummle::Application.routes.draw do
  scope '(:locale)', locale: /en|de/ do
    resources :notes

    get 'about' => 'pages#about'

    get 'signup' => 'users#new'
    post 'signup' => 'users#create'
    get 'edituser' => 'users#edit'
    patch 'edituser' => 'users#update'
    get 'activate' => 'users#activate'
    get 'resend_activation' => 'users#resend_activation'
    get 'forgot_password' => 'users#forgot_password'
    post 'reset_password' => 'users#reset_password'
    get 'new_password' => 'users#new_password'
    patch 'update_password' => 'users#update_password'
    get 'update_email' => 'users#update_email'

    get 'login' => 'sessions#new'
    post 'login' => 'sessions#create'
    get 'logout' => 'sessions#destroy'
  end

  get '/:locale' => 'notes#index'
  root 'notes#index'
end
