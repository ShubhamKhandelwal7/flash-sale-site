class UserPresenter < ApplicationPresenter
  presents :user

  @delegation_methods = [:verified_at]

  delegate *@delegation_methods, to: :user

  def verification_status
    if verified_at.present?
      "You are VERIFIED"
    else
      "NOT VERIFIED"
    end
  end
end
