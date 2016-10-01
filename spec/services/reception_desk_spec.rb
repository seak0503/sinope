require 'rails_helper'

describe ReceptionDesk do
  context '#sign_in' do
    let(:customer) { create(:customer, username: 'taro', password: 'correct_password') }

    example "ユーザー名とパスワードに該当するCustomerオブジェクトを返す" do
      result = ReceptionDesk.new(customer.username, 'correct_password').sign_in
      expect(result).to eq(customer)
    end

    example "該当するユーザー名が存在しない場合はnilを返す" do
      result = ReceptionDesk.new('hanako', 'any_string').sign_in
      expect(result).to be_nil
    end

    example "パスワードが一致しない場合はnilを返す" do
      result = ReceptionDesk.new(customer.username, 'wrong_password').sign_in
      expect(result).to be_nil
    end

    example "パスワード未設定のユーザーを拒絶する" do
      customer.update_column(:password_digest, nil)
      result = ReceptionDesk.new(customer.username, '').sign_in
      expect(result).to be_nil
    end

    example "ログインに成功すると、ユーザーの保有ポイントが1増える" do
      #pending 'Customer#pointsが未実装'
      #customer.stub(:points).and_return(0)
      #上記スタブメソッドはrspec3では利用できないため、下記のように書き換える
      #allow(customer).to receive(:points).and_return(0)
      expect {
        ReceptionDesk.new(customer.username, 'correct_password').sign_in
      }.to change { customer.points }.by(1)
    end
  end
end