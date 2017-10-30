Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :line do
        post 'callback' => 'webhooks#callback'
      end
    end
  end
end
