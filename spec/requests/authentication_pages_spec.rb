require 'spec_helper'

describe "認証画面の" do
  subject {page}
  describe "signin page" do
    before {visit signin_path}
    it {should have_content('Sign in')}
    it {should have_title('Sign in')}
  end

  describe "ログインページ" do
    before{visit signin_path}
    describe "正しくない入力の場合" do
      before {click_button "Sign in"}
      it {should have_title('Sign in')}
      it {should have_selector('div.alert.alert-error', text:'Invalid')}

      describe "他のページに移った後" do
        before {click_link "Home"}
        it {should_not have_selector('div.alert.alert-error')}
      end
    end

    describe "正しい入力の場合" do
      let(:user) {FactoryGirl.create(:user)}
      before do
        fill_in "Email", with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it {should have_title(user.name)}
      it {should have_link('Profile', href:user_path(user))}
      it {should have_link('Sign out', href:signout_path)}
      it {should_not have_link('Sign in', href:signin_path)}

      describe "followed by signout" do
        before {click_link "Sign out"}
        it {should have_link('Sign in')}
      end
    end
  end
end
