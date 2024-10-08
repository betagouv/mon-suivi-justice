class NotificationType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :organization, optional: true
  validates :organization_id, uniqueness: {
    scope: %i[appointment_type_id role], message: 'Cette combinaison rôle / service / type de convocation existe déjà'
  }
  validates :template, presence: true
  validate :template_format
  validate :check_is_default

  enum role: %i[summon reminder cancelation no_show reschedule]
  enum reminder_period: %i[one_day two_days]

  VALID_NOTIFICATION_KEYS = %w[{rdv.heure} {rdv.date} {lieu.nom} {lieu.adresse}
                               {lieu.téléphone} {lieu.contact} {lieu.lien_info}].freeze

  scope :default, -> { where(is_default: true) }

  def setup_template
    template.gsub('{', '%{')
            .gsub('rdv.heure', 'appointment_hour')
            .gsub('rdv.date', 'appointment_date')
            .gsub('lieu.nom', 'place_name')
            .gsub('lieu.adresse', 'place_adress')
            .gsub('lieu.téléphone', 'place_phone')
            .gsub('lieu.contact', 'place_contact')
            .gsub('lieu.lien_info', 'place_preparation_link')
  end

  private

  def template_format
    return unless template&.present? && (template.scan(/{.*?}/) - VALID_NOTIFICATION_KEYS).present?

    errors.add(:template, I18n.t('activerecord.errors.models.notification_type.attributes.template.invalid_format'))
  end

  def check_is_default
    if organization_id.nil? && !is_default
      errors.add(:is_default, 'doit être true si organization_id est nil')
    elsif organization_id.present? && is_default
      errors.add(:is_default, "doit être false si organization_id n'est pas nil")
    end
  end
end
