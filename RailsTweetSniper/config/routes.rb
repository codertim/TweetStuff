FirstApp::Application.routes.draw do

  get "tweets/index"

  get "sessions/new"

  post "tribes/create_members"

  resources :users do
    resources :tribes do
      get 'show_tweets', :on => :member
      get 'new_member',  :on => :member
    end

    get 'edit_tweet_count',   :on => :member
    patch 'update_tweet_count', :on => :member
    get 'twitter_democracy',  :on => :member
    get 'twitter_text',       :on => :member
    get 'snipe_friend',     :on => :member
  end
  resources :sessions, :only => [:new, :create, :destroy]

  get '/about',               :to => "pages#about"
  get '/contact',             :to => "pages#contact"
  get '/goodbye',             :to => "sessions#goodbye"
  get '/pages_twitter_login', :to => "pages#twitter_login"
  get '/signup',              :to => "users#new"
  get '/signin',              :to => "sessions#new"
  delete '/signout',             :to => "sessions#destroy"
  # get '/home',    :to => "pages#home"

  # get '/login_to_twitter', :to => "users#twitter_login"
  get '/auth/:provider/callback', :to => "users#twitter_login"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
