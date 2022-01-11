class StaticPagesController < ApplicationController
  layout 'application_static'

  skip_after_action :verify_authorized

  def landing; end

  def comprendre_mes_mesures; end

  def regles_essentielles; end

  def obligations_personnelles; end

  def sursis_probatoire; end

  def travail_interet_general; end

  def suivi_socio_judiciaire; end

  def stage; end

  def amenagements_de_peine; end

  def preparer_mon_rdv; end

  def preparer_spip92; end

  def preparer_sap_nanterre; end

  def preparer_spip28; end

  def preparer_sap_chartres; end

  def ma_reinsertion; end

  def donnees_personnelles; end
end
