class AdminMailer < ApplicationMailer
  default to: -> { User.admin.pluck(:email) }

  def deal_publish_fail(deal_id)
    if( @deal = Deal.find_by(id: deal_id) )
      #FIXME_AB: include deal id / title in the subject email like "Deal Publish Failed: deal title with id here". So that mails are not clubbed into one  in the inbox.
      mail subject: "Deal Publish Failed: Deal ID[#{deal_id}] Title[#{deal.title}]"
    end
  end
end
