class ApplicationController < ActionController::Base
  #this line is for development purpose
  # protect_from_forgery with: :null_session

  #the following line should be uncommented in production
  protect_from_forgery with: :exception
end
