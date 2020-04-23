namespace :custom do
  desc "This task publishes new deals and unpublishes old expired deals"
  
  task :publish => :environment do
    time_now = Time.current
    Deal.published_on(Date.today).find_each do |deal|
      Rails.logger.info "Deal #{deal.id}: #{deal.title} is being published"
      deal.live_begin = time_now
      deal.live_end = time_now + ENV["DEAL_LIVE_DAYS"].to_i.day
      deal.save
      Rails.logger.info "Deal #{deal.id}: #{deal.title} is now published"
    end
  end
end
