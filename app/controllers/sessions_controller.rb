class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      #認証成功 ユーザーページ(show)にリダイレクト
      sign_in user
      redirect_to user
    else
      #認証失敗 エラーメッセージを表示してサインインフォームを再表示
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end

  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
