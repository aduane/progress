# frozen_string_literal: true

Rails.application.routes.draw do
  get 'started', to: 'channels#create'
  get 'channels/:name', to: 'channels#show', as: :channel
  resources :tasks, only: %i[create update destroy]
  root to: 'visitors#index'
end
