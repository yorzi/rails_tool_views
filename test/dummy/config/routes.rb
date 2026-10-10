Rails.application.routes.draw do
  root "demo#index"
  post "demo/present", to: "demo#create", as: :demo_present
  mount ToolViews::Engine => "/tool_views", as: :tool_views
end
