AWSSnapshots::Application.routes.draw do

 
  root 'dashboard#index'

  resources :activities, :only => [:index]
  resources :dashboard do
    get :load_instances_summary, on: :collection
  end

  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords"}
  devise_scope :user do
   get "logout", to: "devise/sessions#destroy", as: "logout"
 end

  resources :users, only: [:add_aws_creds, :update_aws_creds, :update_password, :add_member, :list_members] do
    get :add_aws_creds, on: :member

    patch :update_aws_creds, on: :member
    patch :update_password, on: :member
    get :list_members, on: :member
    delete :delete_member, on: :member

  end
    get :delete_multiple_member ,to: 'users#delete_multiple_member', as:'delete_multiple_member'
    post 'create_new_member', to: 'users#create_new_member'
    get 'add_member',to: 'users#add_member'
    get 'profile', to: 'users#show'
    get 'change_password', to: 'users#change_password'
    get "edit_aws_creds", to: "users#edit_aws_creds", as: "edit_aws_creds" 
    get 'change_default_region', to: 'users#change_default_region'
    match 'import_csv', to: 'scheduled_snapshots#import_csv', via: [:get, :post]
    match 'schedules/import_csv', to: 'schedules#import_csv', via: [:post]
    match '/scheduled_amis/import_csv', to: 'scheduled_amis#import_csv', via: [:post]

  resources :aws_actions do
    get :load_instances, on: :collection
    get :load_snapshots, on: :collection
    get :load_volumes, on: :collection
    get :create_snapshot, on: :collection
    get :create_instant_snapshot, on: :collection
    get :delete_snapshot, on: :collection
    get :load_volumes_for_instance, on: :collection
    get :create_schedule, on: :collection
    get :wizard_filtered_instances, on: :collection
    get :load_amis, on: :collection
    get :create_ami, on: :collection
    get :delete_ami, on: :collection
    get :load_password_policy, on: :collection
    get :list_all_groups, on: :collection
  end

  resources :elements do
    get :instances, on: :collection
    get :volumes, on: :collection
    get :snapshots, on: :collection
    get :amis, on: :collection
  end

  resources :scheduled_snapshots do
    get :create_csv, on: :collection
  end

  resources :schedules do
    get :fetch_actions, on: :collection
    get :instant_action, on: :collection
    get :export_csv, on: :collection
  end

  resources :scheduled_amis do
    get :fetch_ami_schedule, on: :collection
    get :export_csv, on: :collection
  end

  resources :events

  get '/reload_cost' , to: 'instance_costs#reload_cost'
end
