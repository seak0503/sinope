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
  end
end