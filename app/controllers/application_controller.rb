class ApplicationController < ActionController::Base
  include HomeHelper
  include Pundit
  protect_from_forgery
end
