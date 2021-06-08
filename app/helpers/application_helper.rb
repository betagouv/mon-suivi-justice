module ApplicationHelper
  def active_class_if_url(urls)
    return 'sidebar-active-item' if urls.include?(request.path)
    ''
  end
end
