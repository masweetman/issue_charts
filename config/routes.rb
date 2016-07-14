match 'projects/:project_id/charts', to: 'charts#index', via: :get
match 'projects/:project_id/charts/new', to: 'charts#new', via: :get
match 'projects/:project_id/charts', to: 'charts#create', via: :post

resources :charts