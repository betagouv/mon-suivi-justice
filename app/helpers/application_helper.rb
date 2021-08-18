module ApplicationHelper
  def active_class_if_controller(controller)
    params[:controller] == controller ? 'sidebar-active-item' : ''
  end

  def num_to_phone(num)
    Phone.display(num)
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
end
