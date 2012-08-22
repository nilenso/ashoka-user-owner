class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:user][:email])
    if user && user.authenticate(params[:user][:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash[:error] = "Email/Password is wrong"
      render 'new'
    end 
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end
end
