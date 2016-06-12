Rails.application.routes.draw do
  get '/authenticity_token' => 'sessions#authenticity_token'

  resources :users do
    collection do
      post   'sign_in'      => 'sessions#user_sign_in'
      delete 'sign_out'     => 'sessions#user_sign_out'
      get    'get_by_token' => 'users#get_by_token'
    end
  end

  resources :docs

  get '*path' => redirect('/')
end
