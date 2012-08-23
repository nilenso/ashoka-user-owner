class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def has_signed_in_user?
    current_user.present?
  end
end
