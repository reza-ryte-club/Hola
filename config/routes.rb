Rails.application.routes.draw do
  resources :boxes
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/bx.f/:id', to: 'boxes#get_the_file'
end
