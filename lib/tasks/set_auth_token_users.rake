namespace :custom do
  desc "This task create authentication token for users for accessing their orders API"

  task :set_auth_token_users => :environment do
    Rails.logger.tagged("Task: custom:set_auth_token_users") do
        Rails.logger.info { "setting auth_token for users task started" }

        User.where(authentication_token: nil).find_each do |user|
          Rails.logger.info "User #{user.id}: #{user.name} is being updated with token"
          if user.set_auth_token
            Rails.logger.info "User #{user.id}: #{user.name} is updated"
          else
            Rails.logger.info "User #{user.id}: #{user.name} could not get updated"
          end
        end

        Rails.logger.info { "setting auth_token for users task ended" }
    end
  end
end
