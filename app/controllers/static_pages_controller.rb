class StaticPagesController < ApplicationController
  layout 'application_static'

  skip_after_action :verify_authorized

  def secret; end

  def landing; end

  def comprendre_mes_mesures; end

  def regles_essentielles; end

  def obligations_personnelles; end

  def sursis_probatoire; end

  def travail_interet_general; end

  def suivi_socio_judiciaire; end

  def stage; end

  def amenagements_de_peine; end
end
