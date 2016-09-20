require "rails_helper"

feature 'ログイン' do

  scenario 'ユーザー認証成功' do
    #Customer.stub(:authenticate).and_return(FactoryGirl.create(:customer))
    allow(Customer).to receive(:authenticate).and_return(create(:customer))
    visit root_path
    within('form#new_session') do
      fill_in "username", with: "taro"
      fill_in "password", with: "correct_password"
      click_button "ログイン"
    end
    expect(page).not_to have_css('form#new_session')
  end

  scenario 'ユーザー認証失敗' do
    #Customer.stub(:authenticate)
    allow(Customer).to receive(:authenticate)
    visit root_path
    within("form#new_session") do
      fill_in "username", with: "taro"
      fill_in "password", with: "wrong_password"
      click_button "ログイン"
    end
    expect(page).to have_css('p.alert', text: 'ユーザー名またはパスワードが正しくありません。')
    expect(page).to have_css('form#new_session')
  end
end