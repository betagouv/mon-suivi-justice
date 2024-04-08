module ApplicationHelper
  def active_class_if_controller(controller)
    if controller.is_a?(Array)
      controller.include?(params[:controller]) ? 'fr-nav__item--active' : ''
    else
      params[:controller] == controller ? 'fr-nav__item--active' : ''
    end
  end

  def current?(key, path)
    key.to_s if current_page? path
  end

  def formated_dates_for_select(date_array)
    date_array.map do |date|
      [date.strftime('%d/%m/%Y'), date.to_fs]
    end
  end

  def formated_month_for_select(date_array)
    date_array.map do |date|
      [I18n.l(date, format: '%B %Y').capitalize, date.to_fs]
    end
  end

  def formated_days_for_select(date_array)
    date_array.map do |date|
      [I18n.l(date, format: '%A %d').capitalize, date.to_fs]
    end
  end

  def ten_next_open_days
    twenty_next_days = (Date.today..Date.today + 20).to_a
    open_days = twenty_next_days.select { |d| !d.on_weekend? && Holidays.on(d, :fr) == [] }

    open_days.slice(0, 10)
  end

  def available_places_list
    Place.in_organization(current_organization).map do |place|
      [place.name, place.id]
    end
  end

  def next_valid_day(date: Time.zone.today, day: nil)
    if day.nil?
      valid_day = date.tomorrow
      valid_day = valid_day.tomorrow while valid_day.on_weekend? || Holidays.on(valid_day, :fr).any?
    else
      raise ArgumentError, 'Weekends are not valid days!' if date.next_occurring(day).on_weekend?

      valid_day = date.next_occurring(day)
      valid_day = valid_day.next_occurring(day) while Holidays.on(valid_day, :fr).any?
    end

    valid_day
  end

  def dsfr_class_for(flash_type)
    case flash_type
    when 'notice'
      'info'
    when 'error'
      'error'
    when 'alert'
      'warning'
    else
      flash_type.to_s
    end
  end

  def environment_human_name
    env_names = {
      'mon-suivi-justice-staging' => 'Staging',
      'mon-suivi-justice-demo' => 'Démo',
      /^mon-suivi-justice-staging-pr\d+/ => 'Review'
    }

    return 'Développement' if Rails.env.development?

    return unless Rails.env.production?

    env_names.each do |key, value|
      return value if ENV['APP']&.match?(key)
    end
  end
end
