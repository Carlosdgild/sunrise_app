# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq
  mount Sidekiq::Web => '/sidekiq'
  # Location_informations routes
  resources :location_informations, only: %i[] do
    get :information_range, on: :collection, to: 'location_informations#information_range'
  end
end
