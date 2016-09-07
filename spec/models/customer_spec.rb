require 'rails_helper'

describe Customer do
  %w{family_name given_name family_name_kana given_name_kana}.each do |column_name|
    example "#{column_name} は 空であってはならない" do
      customer = Customer.new(
        family_name: '', given_name: '太郎',
        family_name_kana: 'ヤマダ', given_name_kana: 'タロウ'
      )

      customer[column_name] = ''
      expect(customer).not_to be_valid
      expect(customer.errors[column_name]).to be_present
    end
  end
end