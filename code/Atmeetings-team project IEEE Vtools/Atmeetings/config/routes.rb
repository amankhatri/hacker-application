Atmeetings::Application.routes.draw do
  
  resources :current_meetings

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

  # root :to => 'welcome#index'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  # Team 1 routes
  # please add your routes below
  resources :awards
  resources :meetings
  resources :current_meetings
  resources :speakers
  match "speakers/photograph/:id", :action => 'photograph', :controller => 'speakers', :via => :get, :as => 'photograph'
  resources :awards_display
  # Team 2 routes
  # please add your routes below
  #
  #
  #resource routes
  resources:home_page
  resources:select_meeting
  resources:static_pages
  resources:reports

  #resource route for the session
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end
  
  match "/select" => "select_meeting#index"
  
  #starting with the home page
  get "home_page/index"
  #changing route for home_page and select_meeting page
  root to: 'home_page#index', as: 'home'

  match "/about" => "static_pages#about"


  # Team 3 routes
  # please add your routes below
  #
  #
 
  match 'meeting_registrations/match' => 'meeting_registrations#match'
  match 'meeting_registrations/register' => 'meeting_registrations#register'
  resources :meeting_registrations, :except => [ :destroy, :show, :edit]
  
end
