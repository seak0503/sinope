require 'rails_helper'

describe RewardManager do
  context '#grant_login_points' do
    let(:customer) { create(:customer) }

    example "日付変更時刻をまたいで2回ログインすると、ユーザーの保有ポイントが2増える" do
      Time.zone = 'Tokyo'
      date_boundary = Time.zone.local(2013, 1, 1, 5, 0, 0)
      expect {
        Timecop.freeze(date_boundary.advance(seconds: -1))
        RewardManager.new(customer).grant_login_points
        Timecop.freeze(date_boundary)
        RewardManager.new(customer).grant_login_points
      }.to change { customer.points }.by(2)
    end

    example "日付変更時刻をまたがずに2回ログインしても、ユーザーの保有ポイントは1しか増えない" do
      Time.zone = 'Tokyo'
      date_boundary = Time.zone.local(2013, 1, 1, 5, 0, 0)
      expect {
        Timecop.freeze(date_boundary)
        RewardManager.new(customer).grant_login_points
        Timecop.freeze(date_boundary.advance(hours: 24, seconds: -1))
        RewardManager.new(customer).grant_login_points
      }.to change { customer.points }.by(1)
    end
  end
end