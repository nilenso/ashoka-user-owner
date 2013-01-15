class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale,:make_action_mailer_use_request_host
  helper_method :current_user, :has_signed_in_user?

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

  rescue_from CanCan::AccessDenied do |exception|
    logger.debug "CanCan::AccessDenied exception. Exception: #{exception.inspect}"
    flash[:error] = exception.message
    redirect_to root_url
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def make_action_mailer_use_request_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
