
match 'projects/:project_id/charts/update_options', to: 'charts#update_options', via: :get
match 'charts/:id/update_edit_options', to: 'charts#update_edit_options', via: :get

match 'projects/:project_id/charts', to: 'charts#index', via: :get
match 'projects/:project_id/charts/new', to: 'charts#new', via: :get
match 'projects/:project_id/charts', to: 'charts#create', via: :post

resources :charts