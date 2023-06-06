module PlaceHelper
  def form_main_contact_methods
    Place.main_contact_methods.map do |k, _v|
      [I18n.t("activerecord.attributes.place.main_contact_methods.#{k}"), k]
    end.sort_by(&:last)
  end
end
