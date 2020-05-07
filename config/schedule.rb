# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron


env :PATH, ENV['PATH']
set :output, path + '/log/cron.log'


every 1.minute, roles: [:db] do
# every :day, at: '4:30am', roles: [:db] do
  rake "custom:publish"
end
