Rails.application.routes.draw do
  mount Importmap::Engine => "/importmap"

  get "runtime_importmaps/version", to: "runtime_importmaps#version"
  get "runtime_importmaps/:name", to: "runtime_importmaps#show", as: :runtime_importmap

  root "pages#show"
end