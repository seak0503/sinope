class ReceptionDesk
  attr_accessor :username, :password

  def initialize(username, password)
    self.username = username
    self.password = password
  end

  def sign_in
    customer = Customer.find_by(username: username)
    if customer.try(:password_digest) && BCrypt::Password.new(customer.password_digest) == password
      RewardManager.new(customer).grant_login_points
      customer
    else
      nil
    end
  end
end