module PlaceHelper
  def form_main_contact_methods
    Place.main_contact_methods.map do |k, _v|
      [I18n.t("activerecord.attributes.place.main_contact_methods.#{k}"), k]
    end.sort_by(&:last)
  end

  def archive(place)
    place.discard
    place.agendas.discard_all
    place.agendas.each do |agenda|
      agenda.slot_types.discard_all
    end
  end

  def should_add_transfert_in_error?(place, date)
    place.transfert_in && date < place.transfert_in.date
  end

  def should_add_transfert_out_error?(place, date)
    place.transfert_out && date >= place.transfert_out.date
  end
end
