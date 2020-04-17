class DummyController < ApplicationController
  skip_before_action :authorize

  def dummy_homepage
    render plain: "Dummy action of Dummy controller"
  end
end