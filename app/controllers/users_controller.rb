class UsersController < ApplicationController
  load_and_authorize_resource

  def new
    @user = User.new
  end

  def index
    organization = Organization.find(params[:organization_id])
    @users = organization.field_agents
  end

  def create
    organization = Organization.find(params[:organization_id])
    user = organization.users.new(params[:user])
    user.generate_password
    if user.save
      flash[:notice] = t "users.create.user_created_successfully"
      user.send_password_reset
      redirect_to root_path
    else
      render :new
    end
  end
end
