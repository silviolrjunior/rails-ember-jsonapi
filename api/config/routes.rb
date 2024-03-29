Rails.application.routes.draw do
  # maybe this can be generated automatically
  resources :articles do
    get :author, action: :relationship, relationship: :author
    get 'comments/:id', action: :relationship, relationship: :comments
    get 'tags/:id', action: :relationship, relationship: :tags
    get 'relationships/author', action: :relationships, relationship: :author
    patch 'relationships/author', action: :relationships_update, relationship: :author
    get 'relationships/comments', action: :relationships, relationship: :comments
    patch 'relationships/comments', action: :relationships_update, relationship: :comments
    post 'relationships/comments', action: :relationships_create, relationship: :comments
    delete 'relationships/comments', action: :relationships_destroy, relationship: :comments
    get 'relationships/tags', action: :relationships, relationship: :tags
    patch 'relationships/tags', action: :relationships_update, relationship: :tags
    post 'relationships/tags', action: :relationships_create, relationship: :tags
    delete 'relationships/tags', action: :relationships_destroy, relationship: :tags
  end
  
  resources :photos do
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
