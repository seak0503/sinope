class RewardManager
  attr_accessor :customer

  def initialize(customer)
    self.customer = customer
  end

  def grant_login_points
    Time.zone = 'Tokyo'
    now = Time.current
    if now.hour < 5
      time0 = now.yesterday.midnight.advance(hours: 5)
      time1 = now.midnight.advance(hours: 5)
    else
      time0 = now.midnight.advance(hours: 5)
      time1 = now.tomorrow.midnight.advance(hours: 5)
    end

    unless customer.rewards.where(created_at: time0...time1).exists?
      customer.rewards.create(points: 1)
    end
  end
end