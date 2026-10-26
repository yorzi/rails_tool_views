Rails.application.routes.draw do
  root "demo#index"
  post "demo/present", to: "demo#create", as: :demo_present
  post "demo/lifecycle", to: "demo#lifecycle", as: :demo_lifecycle
  post "demo/cleanup", to: "demo#cleanup", as: :demo_cleanup
  get "agent", to: "agent#show", as: :agent
  post "agent/messages", to: "agent#create", as: :agent_messages
  post "agent/conversations", to: "agent#restart", as: :agent_conversations
  get "v1", to: "v1/demo#support"
  get "v1/customer", to: "v1/demo#customer", as: :v1_customer
  post "v1/customer/new", to: "v1/demo#new_customer", as: :v1_new_customer
  get "v1/support", to: "v1/demo#support", as: :v1_support
  get "v1/review", to: "v1/demo#review", as: :v1_review
  post "v1/review/new", to: "v1/demo#new_artifact", as: :v1_new_artifact
  post "v1/identity", to: "v1/demo#identity", as: :v1_identity
  get "v1/exports/:id", to: "v1/exports#show", as: :v1_export
  mount RailsToolViews::Engine => "/rails_tool_views", as: :rails_tool_views
end
