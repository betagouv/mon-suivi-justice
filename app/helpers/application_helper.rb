module ApplicationHelper
  def active_class_if_controller(controller)
    if controller.is_a?(Array)
      controller.include?(params[:controller]) ? 'fr-nav__item--active' : ''
    else
      params[:controller] == controller ? 'fr-nav__item--active' : ''
    end
  end

  def current?(key, path)
    if current_page? path
      "#{key}" 
    else
      nil
    end
  end

  def formated_dates_for_select(date_array)
    formated = []

    date_array.each do |date|
      formated << [date.strftime('%d/%m/%Y'), date]
    end

    formated
  end

  def formated_month_for_select(date_array)
    formated = []

    date_array.each do |date|
      formated << [(I18n.l date, format: '%B %Y').capitalize, date]
    end

    formated
  end

  def formated_days_for_select(date_array)
    formated = []

    date_array.each do |date|
      formated << [(I18n.l date, format: '%A %d').capitalize, date]
    end

    formated
  end

  def ten_next_open_days
    twenty_next_days = (Date.today..Date.today + 20).to_a
    open_days = twenty_next_days.select { |d| !d.on_weekend? && Holidays.on(d, :fr) == [] }

    open_days.slice(0, 10)
  end

  def available_places_list
    list = []

    Place.in_organization(current_organization).each do |place|
      list << [place.name, place.id]
    end

    list
  end
end
