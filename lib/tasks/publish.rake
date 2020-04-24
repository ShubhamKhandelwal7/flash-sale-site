namespace :custom do
  desc "This task publishes new deals and unpublishes old expired deals"
  
  task :publish => :environment do
    time_now = Time.current
    Deal.published_on(Date.today).find_each do |deal|
      deal.live_begin = time_now
      deal.live_end = time_now + 1.day
      deal.save!
    end
  end
end
