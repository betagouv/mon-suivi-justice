class ManageNotificationProblems < ApplicationJob
  queue_as :default

  def perform
    inform_users_about_failed_notifications
    inform_admins
  end

  private

  def inform_users_about_failed_notifications
    notifications_to_be_marked_as_failed.each do |notification|
      notification.handle_unsent!
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end

  def inform_admins
    return unless notifications_to_be_marked_as_failed.any?

    AdminMailer.notifications_problems(
      notifications_to_be_marked_as_failed.pluck(:id)
    ).deliver_later
  end

  def notifications_to_be_marked_as_failed
    @notifications_to_be_marked_as_failed ||= Notifications::ToBeMarkedAsFailedQuery.new.call
  end
end
