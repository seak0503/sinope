require 'rails_helper'

describe Customer do
  context 'バリデーション' do
    let(:customer) { build(:customer) }

    example '妥当なオブジェクト' do
      expect(customer).to be_valid
    end

    %w{family_name given_name family_name_kana given_name_kana}.each do |column_name|
      example "#{column_name} は 空であってはならない" do
        customer[column_name] = ''
        expect(customer).not_to be_valid
        expect(customer.errors[column_name]).to be_present
      end

      example "#{column_name} は40文字以内" do
        customer[column_name] = 'ア' * 41
        expect(customer).not_to be_valid
        expect(customer.errors[column_name]).to be_present
      end

      example "#{column_name} に含まれる半角カタカナは全角カタカナに変換して受け入れる" do
        customer[column_name] = 'ｱｰﾝ'
        expect(customer).to be_valid
        expect(customer[column_name]).to eq('アーン')
      end
    end

    %w{family_name given_name}.each do |column_name|
      example "#{column_name} は漢字、ひらがな、カタカナを含んでもよい" do
        customer[column_name] = '亜あアーン'
        expect(customer).to be_valid
      end

      example "#{column_name} は漢字、ひらなが、カタカナ以外の文字を含まない" do
        ['A', '1', '@'].each do |value|
          customer[column_name] = value
          expect(customer).not_to be_valid
          expect(customer.errors[column_name]).to be_present
        end
      end
    end

    %w{family_name_kana given_name_kana}.each do |column_name|
      example "#{column_name} はカタカナのみ含む" do
        customer[column_name] = 'アーン'
        expect(customer).to be_valid
      end

      example "#{column_name} はカタカナ以外の文字を含まない" do
        ['亜', 'A', '1', '@'].each do |value|
          customer[column_name] = value
          expect(customer).not_to be_valid
          expect(customer.errors[column_name]).to be_present
        end
      end

      example "#{column_name} に含まれるひらがなはカタカナに変換して受け入れる" do
        customer[column_name] = 'あーん'
        expect(customer).to be_valid
        expect(customer[column_name]).to eq('アーン')
      end
    end
  end

  context '.authenticate' do
    let(:customer) { create(:customer, username: 'taro', password: 'correct_password') }

    example "ユーザー名とパスワードに該当するCustomerオブジェクトを返す" do
      result = Customer.authenticate(customer.username, 'correct_password')
      expect(result).to eq(customer)
    end

    example "パスワードが一致しない場合はnilを返す" do
      result = Customer.authenticate(customer.username, 'wrong_password')
      expect(result).to be_nil
    end

    example "該当するユーザー名が存在しない場合はnilを返す" do
      result = Customer.authenticate('hanako', 'any_string')
      expect(result).to be_nil
    end

    example "パスワード未設定のユーザーを拒絶する" do
      customer.update_column(:password_digest, nil)
      result = Customer.authenticate(customer.username, '')
      expect(result).to be_nil
    end

    example "ログインに成功すると、ユーザーの保有ポイントが1増える" do
      #pending 'Customer#pointsが未実装'
      #customer.stub(:points).and_return(0)
      #上記スタブメソッドはrspec3では利用できないため、下記のように書き換える
      #allow(customer).to receive(:points).and_return(0)
      expect {
        Customer.authenticate(customer.username, 'correct_password')
      }.to change { customer.points }.by(1)
    end

    example "日付変更時刻をまたいで2回ログインすると、ユーザーの保有ポイントが2増える" do
      Time.zone = 'Tokyo'
      date_boundary = Time.zone.local(2013, 1, 1, 5, 0, 0)
      expect {
        Timecop.freeze(date_boundary.advance(seconds: -1))
        Customer.authenticate(customer.username, 'correct_password')
        Timecop.freeze(date_boundary)
        Customer.authenticate(customer.username, 'correct_password')
      }.to change { customer.points }.by(2)
    end

    example "日付変更時刻をまたがずに2回ログインしても、ユーザーの保有ポイントは1しか増えない" do
      Time.zone = 'Tokyo'
      date_boundary = Time.zone.local(2013, 1, 1, 5, 0, 0)
      expect {
        Timecop.freeze(date_boundary)
        Customer.authenticate(customer.username, 'correct_password')
        Timecop.freeze(date_boundary.advance(hours: 24, seconds: -1))
        Customer.authenticate(customer.username, 'correct_password')
      }.to change { customer.points }.by(1)
    end
  end

  context 'password' do
    let(:customer) { build(:customer, username: 'taro') }

    example "生成されたpassword_digestは60文字" do
      customer.password = 'any_string'
      customer.save!
      expect(customer.password_digest).not_to be_nil
      expect(customer.password_digest.size).to eq(60)
    end

    example "空文字を与えるとpassword_digestはnil" do
      customer.password = ''
      customer.save!
      expect(customer.password_digest).to be_nil
    end
  end

  context '#points' do
    let(:customer) { create(:customer, username: 'taro') }

    example "関連付けられたRewardのpointsを合計して返す" do
      customer.rewards.create(points: 1)
      customer.rewards.create(points: 5)
      customer.rewards.create(points: -2)

      expect(customer.points).to eq(4)
    end
  end
end