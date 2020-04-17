class HomeControllerPolicy 
  attr_reader :user, :ctrlr

  def initialize(user, ctrlr)
    @user = user
    @ctrlr = ctrlr
  end

  def dashboard?
    # TODO: add roles to Auth0
#    puts "---START---"
#    puts user
#    puts "---ROLE"
#    puts user['client_metadata']
    user['info']['name'] == "Julia Smith"
  end

end
