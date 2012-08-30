class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def default_url_options(options={})
    return { :locale => I18n.locale } unless I18n.locale == I18n.default_locale
    return { :locale => nil }
  end

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def has_signed_in_user?
    current_user.present?
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
