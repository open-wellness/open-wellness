class Auth0Controller < ApplicationController
  def callback
    session[:userinfo] = request.env['omniauth.auth']
    redirect_to '/dashboard'
  end
  
  def failure
    error_msg = request.env['omniauth.error']
    error_type = request.env['omniauth.error.type']

    # It's up to you what you want to do with the error information
    # You could display it to the user or log it somehow.
    Rails.logger.debug("Auth0 Error: #{error_msg}. Error Type: #{error_type}")

    render :failure
  end
  
  def logout
    reset_session
    redirect_to root_path
  end
end
