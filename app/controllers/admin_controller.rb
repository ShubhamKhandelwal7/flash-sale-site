class AdminController < ApplicationController
  before_action :authorize_for_admin
  
end
