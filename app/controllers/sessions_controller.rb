class SessionsController < ApplicationController
  before_filter :organization_active?, :only => :create
  before_filter :user_active?, :only => :create

  def new
    @user = User.new
    session[:return_to] = params[:return_to] if params[:return_to]
    @applications = Doorkeeper::Application.all
  end

  def create
    user = User.maybe(User.find_by_email(params[:user][:email].downcase))
    if user.authenticate(params[:user][:password])
      session[:user_id] = user.id
      flash[:notice] = t "log_in_successful"
      redirect_to(session.delete(:return_to) || root_path)
    else
      flash[:error] = t "wrong_email_password"
      redirect_to login_path
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def organization_active?
    user = User.maybe(User.find_by_email(params[:user][:email].downcase))
    if !user.super_admin? && !user.organization_active?
      redirect_to(deactivated_path) 
    end
  end

  def user_active?
    user = User.maybe(User.find_by_email(params[:user][:email].downcase))
    user.active?
    unless user.active?
      flash[:error] = "You are not authorized to access this page."
      redirect_to(root_path)
    end
  end
end
