module Api
  module V1
    class OrganizationsController < ActionController::Base
      skip_authorize_resource
      doorkeeper_for :all
      respond_to :json

      def index
        organizations = Organization.active_organizations
        respond_with organizations.to_json(:only => [:id, :name])
      end
    end
  end
end
