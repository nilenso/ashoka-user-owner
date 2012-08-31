class UsersController < ApplicationController
  load_and_authorize_resource

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.organization_id = params[:organization_id]
    @user.role = 'user'
    if @user.save
      redirect_to root_path
    else
      render :new
    end
  end
end
