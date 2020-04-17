module UserVerification
  extend ActiveSupport::Concern

  # this is used as before action to load user via token
  def current_user_via_token(token_column)
    #FIXME_AB: remove unwanted code
    @plain = token_column

    @user = User.find_by(token_column => params[:token])
    #FIXME_AB: don't raise exception, redirect user to login/home page if user not found with the token
  rescue ActiveRecord::RecordNotFound
  end

end
