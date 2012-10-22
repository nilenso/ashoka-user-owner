class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user
      user.send_password_reset
      flash[:notice] = "Email sent with password reset instructions."
      redirect_to root_path
    else
      flash[:error] = "Email address not valid"
      redirect_to new_password_reset_path
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.reset_password(params[:user][:password],params[:user][:password_confirmation])
      reset_session
      redirect_to root_path, :notice => t("password_resets.success")
    else
      render :edit
    end
  end
end
