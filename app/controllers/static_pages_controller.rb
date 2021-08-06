class StaticPagesController < ApplicationController
  layout 'application'

  skip_after_action :verify_authorized

  def home; end

  def comprendre_mes_mesures; end
end
