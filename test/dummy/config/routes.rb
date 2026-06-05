Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  root "imports#index"
  mount Importmap::Engine => "/importmap"
end
