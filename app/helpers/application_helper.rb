module ApplicationHelper
  def active_class_if_url(urls)
    return 'sidebar-active-item' if urls.include?(request.path)

    ''
  end

  def num_to_phone(num)
    "#{num[0..1]} #{num[2..3]} #{num[4..5]} #{num[6..7]} #{num[8..]}"
  end
end
