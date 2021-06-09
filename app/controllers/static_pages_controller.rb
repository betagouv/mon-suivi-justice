class StaticPagesController < ApplicationController
  layout 'application'

  def home
    skip_authorization
  end
end
