class NotificationType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  validates :template, presence: true
  validate :template_format

  enum role: %i[summon reminder cancelation no_show reschedule]
  enum reminder_period: %i[one_day two_days]

  VALID_NOTIFICATION_KEYS = %w[{rdv.heure} {rdv.date} {lieu.nom} {lieu.adresse}
                               {lieu.téléphone} {lieu.contact} {lieu.lien_info}].freeze

  private

  def template_format
    return unless template&.present? && (template.scan(/{.*?}/) - VALID_NOTIFICATION_KEYS).present?

    errors.add(:template, I18n.t('activerecord.errors.models.notification_type.attributes.template.invalid_format'))
  end
end
