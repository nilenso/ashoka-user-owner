require_dependency "req_conf/application_controller"

module ReqConf
  class ConfirmationController < ApplicationController
    def new
      @submit_path = params[:redirect_to]
      @method = params[:method].to_sym
    end
  end
end
