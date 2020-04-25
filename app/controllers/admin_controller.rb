class AdminController < ApplicationController
  layout 'admin'
  before_action :authorize_for_admin
  #FIXME_AB: Lets have a separate layout for admin controllers, with its own different navigation links
end
