class AdminMailer < ApplicationMailer
  default to: -> { User.admin.pluck(:email) }

  def deal_publish_fail(deal_id)
    if( @deal = Deal.find_by(id: deal_id) )
      mail subject: "Deal publish failure"
    end
  end
end