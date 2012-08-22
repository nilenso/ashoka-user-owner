class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account successfully created"
      redirect_to root_path
    else
      flash[:error] = "Errors encountered, how electrifying !!"
      render 'new'
    end
  end
end
