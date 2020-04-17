module UserVerification
  extend ActiveSupport::Concern

  def current_user_via_token(token_column)
    @plain = token_column
    @user = User.find_by(token_column => params[:token])
  rescue ActiveRecord::RecordNotFound
  end
  
end