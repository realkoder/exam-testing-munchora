Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  mount ActionCable.server => '/cable/notify'

  namespace :api do
    namespace :v1 do
      get '/test', to: 'test#test'

      # AUDITS
      resources :grocery_list_audits, only: [:index]
      resources :grocery_list_item_audits, only: [:index]
      resources :user_audits, only: [:index]

      # AUTH
      get '/auth/google', to: 'auth#google'
      get '/auth/google/callback', to: 'auth#google_callback'
      post '/auth/login', to: 'auth#login'
      delete '/auth/logout', to: 'auth#logout'
      get '/auth/me', to: 'auth#me'

      # FEEDBACK
      resources :feedbacks, only: [:index, :show, :create, :destroy]

      # GROCERY_LISTS
      resources :grocery_lists, only: [:index, :create, :update, :destroy] do
        member do
          post 'add-item', action: :add_item
          delete 'remove-item/:item_id', action: :remove_item
          patch 'update-item/:item_id', action: :update_item
          post 'share', action: :share
          delete 'unshare', action: :unshare
        end
      end

      # INVOICE
      resources :invoices, only: [:index, :show] do
        member do
          post :pay
        end
      end

      # LLM
      post 'llm/generate-recipe', to: 'llm#generate_recipe'
      post 'llm/generate-recipe-image/:id', to: 'llm#generate_recipe_image'
      put 'llm/update-recipe/:id', to: 'llm#update_recipe'

      # USERS
      delete 'users/delete-image', to: 'users#delete_image'
      post 'users/upload-image', to: 'users#upload_image'
      resources :users, only: [:index, :show, :create, :update, :destroy]

      # RECIPES
      resources :recipes, only: [:index, :show, :update, :destroy] do
        member do
          # image
          post 'upload-image', to: 'recipes#upload_image'
          delete 'delete-image', to: 'recipes#delete_image'

          # comments
          post 'comments', to: 'recipes#add_comment'
          delete 'comments/:comment_id', to: 'recipes#delete_comment'

          # likes
          post 'likes', to: 'recipes#add_like'
          delete 'likes', to: 'recipes#delete_like'
        end
      end

      # RECIPE_SUGGESTIONS
      resources :recipe_suggestions, only: [:index]

      # RECIPE_SUMMARY_VIEW
      resources :recipe_summary, only: [:index]

      # SUBSCRIPTION
      resources :subscriptions, only: [:index, :show, :create] do
        member do
          post :cancel
        end
      end
    end
  end

  match '*path', via: :all, to: 'application#route_not_found'
end
