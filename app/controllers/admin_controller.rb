class AdminController < ApplicationController
  layout 'admin'
  before_action :authorize_for_admin
end
