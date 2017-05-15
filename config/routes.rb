# frozen_string_literal: true

Rails.application.routes.draw do
  get 'started', to: 'channels#create'
  root to: 'visitors#index'
end
