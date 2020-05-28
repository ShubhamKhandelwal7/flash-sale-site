namespace :custom do
  desc "This task create authentication token for users for accessing their orders API"

  task :set_auth_token_users => :environment do
    Rails.logger.tagged("Task: custom:set_auth_token_users") do
        Rails.logger.info { "setting auth_token for users task started" }

        #FIXME_AB: User.verified.without_auth_token.find_each
        User.verified.without_auth_token.find_each do |user|
          Rails.logger.info "User #{user.id}: #{user.name} is being updated with token"
          #FIXME_AB: user.set_auth_token!
          if user.set_auth_token!
            Rails.logger.info "User #{user.id}: #{user.name} is updated"
          else
            Rails.logger.info "User #{user.id}: #{user.name} could not get updated"
          end
        end

        Rails.logger.info { "setting auth_token for users task ended" }
    end
  end
end
