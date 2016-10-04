require 'rails_helper'

describe ReceptionDesk, '#sign_in' do
  let(:customer) { create(:customer, username: 'taro', password: 'correct_password') }

  context 'ユーザー名とパスワードが一致する場合' do

    example "該当するCustomerオブジェクトを返す" do
      result = ReceptionDesk.new(customer.username, 'correct_password').sign_in
      expect(result).to eq(customer)
    end

    example "RewardManager#grant_login_pointsが呼ばれる" do
      expect_any_instance_of(RewardManager).to receive(:grant_login_points)
      ReceptionDesk.new(customer.username, 'correct_password').sign_in
    end
  end

  context '該当するユーザー名が存在しない場合' do
    example "nilを返す" do
      result = ReceptionDesk.new('hanako', 'any_string').sign_in
      expect(result).to be_nil
    end

    example "RewardManager#grant_login_pointsは呼ばれない" do
      expect_any_instance_of(RewardManager).not_to receive(:grant_login_points)
      ReceptionDesk.new('hanako', 'any_string').sign_in
    end
  end

  context 'パスワードが一致しない場合' do
    example "nilを返す" do
      result = ReceptionDesk.new(customer.username, 'wrong_password').sign_in
      expect(result).to be_nil
    end

    example "RewardManager#grant_login_pointsは呼ばれない" do
      expect_any_instance_of(RewardManager).not_to receive(:grant_login_points)
      ReceptionDesk.new(customer.username, 'wrong_password').sign_in
    end
  end

  context 'パスワード未設定の場合' do
    before { customer.update_column(:password_digest, nil) }

    example 'nilを返す' do
      result = ReceptionDesk.new(customer.username, '').sign_in
      expect(result).to be_nil
    end

    example 'RewardManager#grant_login_pointsは呼ばれない' do
      expect_any_instance_of(RewardManager).not_to receive(:grant_login_points)
      ReceptionDesk.new(customer.username, 'wrong_password').sign_in
    end
  end

  #example "ログインに成功すると、ユーザーの保有ポイントが1増える" do
  #  pending 'Customer#pointsが未実装'
  #  customer.stub(:points).and_return(0)
  #  #上記スタブメソッドはrspec3では利用できないため、下記のように書き換える
  #  allow(customer).to receive(:points).and_return(0)
  #  expect {
  #    ReceptionDesk.new(customer.username, 'correct_password').sign_in
  #  }.to change { customer.points }.by(1)
  #end
end