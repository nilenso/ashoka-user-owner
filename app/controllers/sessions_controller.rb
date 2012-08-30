class SessionsController < ApplicationController
  before_filter :organization_approved, :only => :create
  def new
    session[:return_to] = params[:return_to] if params[:return_to]
  end

  def create
    user = User.find_by_email(params[:user][:email])
    if user && user.authenticate(params[:user][:password])
      session[:user_id] = user.id
      redirect_to(session.delete(:return_to) || root_path)
    else
      flash[:error] = t "wrong_email_password"
      render action: 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private

  def organization_approved
    user = User.find_by_email(params[:user][:email])
    if user.present?
      redirect_to(pending_path) unless  user.admin? || user.organization.approved?
    end
  end
end
