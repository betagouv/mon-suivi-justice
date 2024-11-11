class HandleMisroutedNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    return if phones_to_reroute.empty?

    AdminMailer.with(phones: phones_to_reroute).warn_link_mobility_for_misrouted_notifications.deliver_later
  end

  private

  def phones_to_reroute
    @phones_to_reroute ||= Notification.to_reroute_link_mobility.pluck(:target_phone).uniq
  end
end
