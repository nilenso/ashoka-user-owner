require 'active_support/concern'

module ReqConf
  module Concerns
    module RequirePasswordConfirmation
      extend ActiveSupport::Concern

      module ClassMethods
        def require_password_confirmation_for(action)
          before_filter :check_password, :only => action
        end
      end

      def check_password
        unless current_user.authenticate(params[:password])
          redirect_to req_conf.new_confirmation_path(:redirect_to => request.fullpath, :method => request.request_method)
        end
      end
    end
  end
end
