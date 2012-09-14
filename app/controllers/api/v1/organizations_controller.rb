module Api
  module V1
    class OrganizationsController < ActionController::Base
      doorkeeper_for :all
      respond_to :json

      def index
        @organizations = Organization.where(:status => "approved")
        respond_with @organizations.to_json(:only => [:id, :name])
      end
    end
  end
end
