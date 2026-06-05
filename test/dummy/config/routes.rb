Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  mount Importmap::Engine => "/importmap"
end
