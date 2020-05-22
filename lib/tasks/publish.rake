namespace :custom do
  desc "This task publishes new deals and unpublishes old expired deals"

  task :publish => :environment do
    Rails.logger.tagged("Task: custom:publish") do
        Rails.logger.info { "Publishing deals task started" }

        Deal.published_on(Date.today).find_each do |deal|
          Rails.logger.info "Deal #{deal.id}: #{deal.title} is being published"
          if deal.live!
            Rails.logger.info "Deal #{deal.id}: #{deal.title} is now published"
          else
            Rails.logger.info "Deal #{deal.id}: #{deal.title} could not get published"
            AdminMailer.deal_publish_fail(deal.id).deliver_later
          end
        end

        Rails.logger.info { "Publishing deals task ended" }
    end


  end
end

