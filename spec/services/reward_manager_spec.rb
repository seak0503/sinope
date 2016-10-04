require 'rails_helper'

describe RewardManager, '#grant_login_points' do
  let(:customer) { create(:customer) }
  let(:date_boundary) { Time.zone.local(2013, 1, 1, 5, 0, 0) }

  before { Time.zone = 'Tokyo' }

  example '土曜日の午前5時直前にログインすると、ユーザーの保有ポイントが1増える' do
    Timecop.freeze(Time.zone.local(2013, 1, 5, 4, 59, 59))
    expect {
      RewardManager.new(customer).grant_login_points
    }.to change { customer.points }.by(1)
  end

  example '土曜日の午前5時にログインすると、ユーザーの保有ポイントが3増える' do
    Timecop.freeze(Time.zone.local(2013, 1, 5, 5, 0, 0))
    expect {
      RewardManager.new(customer).grant_login_points
    }.to change { customer.points }.by(3)
  end

  example '日曜日の午前5時直前にログインすると、ユーザーの保有ポイントが3増える' do
    Timecop.freeze(Time.zone.local(2013, 1, 6, 4, 59, 59))
    expect {
      RewardManager.new(customer).grant_login_points
    }.to change { customer.points }.by(3)
  end

  example '日曜日の午前5時にログインすると、ユーザーの保有ポイントが1増える' do
    Timecop.freeze(Time.zone.local(2013, 1, 6, 5, 0, 0))
    expect {
      RewardManager.new(customer).grant_login_points
    }.to change { customer.points }.by(1)
  end

  example "日付変更時刻をまたいで2回ログインすると、ユーザーの保有ポイントが2増える" do
    expect {
      Timecop.freeze(date_boundary.advance(seconds: -1))
      RewardManager.new(customer).grant_login_points
      Timecop.freeze(date_boundary)
      RewardManager.new(customer).grant_login_points
    }.to change { customer.points }.by(2)
  end

  example "日付変更時刻をまたがずに2回ログインしても、ユーザーの保有ポイントは1しか増えない" do
    expect {
      Timecop.freeze(date_boundary)
      RewardManager.new(customer).grant_login_points
      Timecop.freeze(date_boundary.advance(hours: 24, seconds: -1))
      RewardManager.new(customer).grant_login_points
    }.to change { customer.points }.by(1)
  end
end