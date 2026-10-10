ToolViews::Engine.routes.draw do
  get "surfaces/:id", to: "surfaces#show", as: :surface
  post "surfaces/:id/actions", to: "surfaces#act", as: :surface_actions
  post "surfaces/:id/continuations/:interaction_id", to: "surfaces#retry_agent", as: :surface_continuation
end
