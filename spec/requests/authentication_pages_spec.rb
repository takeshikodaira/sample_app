require 'spec_helper'

describe "認証画面の" do
  subject {page}
  describe "signin page" do
    before {visit signin_path}
    it {should have_content('Sign in')}
    it {should have_title('Sign in')}
  end

  describe "ログインページで" do
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

    describe "正しい入力でログイン後" do
      let(:user) {FactoryGirl.create(:user)}
      before {sign_in user}

      it {should have_title(user.name)}
      it {should have_link('Users', href: users_path)}
      it {should have_link('Profile', href: user_path(user))}
      it {should have_link('Setting', href: edit_user_path(user))}
      it {should have_link('Sign out', href: signout_path)}
      it {should_not have_link('Sign in', href:signin_path)}
    end

    describe "認証時" do
      describe "ログインしていないユーザー" do
        let(:user) {FactoryGirl.create(:user)}

        describe "保護されたページにアクセスしようとした時" do
          before do
            visit edit_user_path(user)
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
          end

          describe "ログインした後" do
            it "望ましいページを表示" do
              expect(page).to have_title('Edit user')
            end
          end

          describe "もう一度ログインしたとき" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end
            it "転送先が消えてデフォルトのページ(プロフィール)に行くべき" do
              expect(page).to have_title(user.name)
            end
          end

        end

        describe "Usersコントローラーの" do
          describe "eidtページを開く" do
            before {visit edit_user_path(user)}
            it {should have_title('Sign in')}
          end

          describe "update actionを送信" do
            before {patch user_path(user)}
            specify {expect(response).to redirect_to(signin_path)}
          end

          describe "ユーザー一覧にアクセス" do
            before {visit users_path}
            it {should have_title('Sign in')}
          end
        end

        describe "Micropostsコントローラーの" do
          describe "createアクションを送信" do
            before {post microposts_path}
            specify {expect(response).to redirect_to(signin_path)}
          end
          describe "destroyアクションを送信" do
            before {delete micropost_path(FactoryGirl.create(:micropost))}
            specify {expect(response).to redirect_to(signin_path)}
          end
        end

      end

      describe "別のユーザーとして" do
        let(:user) {FactoryGirl.create(:user)}
        let(:wrong_user) {FactoryGirl.create(:user, email: "wrong@example.com")}
        before {sign_in user, no_capybara: true}

        describe "GETリクエストをUsers#editアクションに送信" do
          before {get edit_user_path(wrong_user)}
          specify {expect(response.body).not_to match(full_title('Edit user'))}
          specify {expect(response).to redirect_to(root_url)}
        end

        describe "PATCHリクエストをUsers#updateアクションに送信" do
          before {patch user_path(wrong_user)}
          specify {expect(response).to redirect_to(root_path)}
        end
      end

      describe "非管理者ユーザーとして" do
        let(:user) {FactoryGirl.create(:user)}
        let(:non_admin) {FactoryGirl.create(:user)}

        before {sign_in non_admin, no_capybara: true}
        describe "Users#destroyアクションにDELETEリクエストを送信" do
          before {delete user_path(user)}
          specify {expect(response).to redirect_to(root_path)}
        end
      end

    end

  end
end





















