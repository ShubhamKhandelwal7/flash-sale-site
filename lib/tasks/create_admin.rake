namespace :custom do
  desc "Creates admin by getting its details from console"
  
  task :create_admin => :environment do
    Rails.logger.tagged("Task: admin:create") do
      Rails.logger.info { "Admin creation task started" }
      STDOUT.puts "Enter admin name:"
      name = STDIN.gets.strip
      STDOUT.puts "Enter admin email_id:"
      email = STDIN.gets.strip
      STDOUT.puts "Enter password:"
      password = STDIN.gets.strip
      
      user = User.new(name: name, email: email, password: password, admin: true, verified_at: Time.current)
      if user.save
        STDOUT.puts "Admin created" 
        Rails.logger.info { "Admin #{user.name} successfully created" }
      else
        Rails.logger.info { "Admin #{user.name} failed to be created" }
        STDOUT.puts "Admin not created: Validation Errors"  
        user.errors.messages.each { |error| STDOUT.puts "#{error[0]}: #{error[1]}"  }
      end
      Rails.logger.info { "Admin creation task ended" }
    end
  end 
end