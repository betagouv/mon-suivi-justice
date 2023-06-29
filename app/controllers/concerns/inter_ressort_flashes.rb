module InterRessortFlashes
  extend ActiveSupport::Concern

  def set_inter_ressort_flashes
    link_to_edit = "<a href='/convicts/#{@convict.id}/edit'>en cliquant ici</a>"
    change_city = I18n.t('convicts.set_inter_ressort_flashes.change_city')
    add_city = I18n.t('convicts.set_inter_ressort_flashes.add_city')
    set_city = @convict.city_id ? change_city : add_city

    available_organizations = I18n.t('convicts.set_inter_ressort_flashes.available_organizations')
    organizations_list = @convict.organizations.pluck(:name).join(', ')
    how_to_add_organizations = I18n.t('convicts.set_inter_ressort_flashes.how_to_add_organizations', msg: set_city)

    warning_message = "#{available_organizations} #{organizations_list}. <br/>
      #{how_to_add_organizations} #{link_to_edit}".html_safe

    flash.now[:info] = warning_message
  end
end
