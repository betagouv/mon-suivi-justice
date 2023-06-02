module InterRessortFlashes
  extend ActiveSupport::Concern

  def set_inter_ressort_flashes
    link_to_edit = "<a href='/convicts/#{@convict.id}/edit'>en cliquant ici</a>"

    flash.now[:warning] =
      "#{I18n.t('convicts.set_inter_ressort_flashes.available_services')}
         #{@convict.organizations.pluck(:name).join(', ')}.
          #{I18n.t('convicts.set_inter_ressort_flashes.how_to_add_services')} #{link_to_edit}".html_safe
  end
end
