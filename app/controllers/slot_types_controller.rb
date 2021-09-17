class SlotTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @slot_types = SlotTypes.all
    authorize @slot_types
  end
end

#
# TODO : create / delete slot type : no edit, so slot are syncro
#
# Un exemple, pour confirmer,
# En tant qu'agent du point justice de gennevilier,
# Je ne vois que les RDVs du point justice de gennevilier,
# Et je ne peux créer des RDV que pour le point justice gennevilier
