namespace :custom do
  desc "This task publishes new deals and unpublishes old expired deals"
  
  task :publish => :environment do
    date_today = Date.today
    time_now = Time.current
    Deal.find_each do |deal|
      if deal.published_at&.to_date == date_today
        deal.live_begin = time_now
        deal.live_end = time_now + 1.day
        deal.save!
      end
    end
  end
end