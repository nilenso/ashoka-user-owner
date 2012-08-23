module Api
  module V1
    class UsersController < ActionController::Base
      doorkeeper_for :all
      respond_to :json

      def show
        respond_with current_user.as_json(:except => :password_digest)
      end

      private

      def current_user
        if doorkeeper_token
          @current_user ||= User.find(doorkeeper_token.resource_owner_id)
        end
      end
    end
  end
end
