class SessionsController < ApplicationController
  def new
    # x @session = Session.new
    # o scope: :session + utl: login_path
  end

  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end