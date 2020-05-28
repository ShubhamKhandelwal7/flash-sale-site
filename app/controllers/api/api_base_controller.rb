module Api

  class ApiBaseController < ActionController::Base

    def authorize_by_api_token
      if current_user.blank?
        render plain: "Invalid Token", status: 422
      end
    end

    private def current_user
      @current_user ||= User.verified.find_by(authentication_token: params[:token])
    end

  end
end