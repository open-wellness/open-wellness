module ViewHelper
  include Pagy::Frontend
  
  def greeting
    if current_user.present?
      @greeting = "Welcome, #{current_user['info']['name'].split.first}!"
      @link = dashboard_path
    else
      @greeting = 'Open Wellness'
      @link = root_path
    end
  end

  def login_or_out
    if current_user.present?
      link_to('Log Out', logout_path, class: 'nav-link')
    else
      link_to('Log In', authentication_path, method: :post, class: 'nav-link')
    end
  end
end
