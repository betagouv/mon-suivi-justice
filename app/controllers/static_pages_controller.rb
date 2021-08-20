class StaticPagesController < ApplicationController
  layout 'application'

  skip_after_action :verify_authorized

  def landing; end

  def comprendre_mes_mesures; end

  def sursis_probatoire; end

  def travail_interet_general; end

  def suivi_socio_judiciaire; end

  def stage; end
end
