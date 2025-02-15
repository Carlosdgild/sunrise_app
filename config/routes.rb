# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq
  mount Sidekiq::Web => '/sidekiq'
end
