class DailyPublishDealsJob < ApplicationJob
  queue_as :default

  def perform
    reschedule_job
    Rake.Task['custom:publish'].execute
  end

  def reschedule_job
    self.class.set(wait_until:
    Time.current.tomorrow).perform_later
  end
end