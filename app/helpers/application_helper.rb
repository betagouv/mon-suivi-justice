module ApplicationHelper
  def active_class_if_url(urls)
    return 'sidebar-active-item' if urls.include?(request.path)

    ''
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
end
