class Convict < ApplicationRecord
  include NormalizedPhone
  has_paper_trail

  has_many :appointments, dependent: :destroy
  has_many :history_items, dependent: :destroy

  has_many :areas_convicts_mappings, dependent: :destroy
  has_many :departments, through: :areas_convicts_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_convicts_mappings, source: :area, source_type: 'Jurisdiction'

  attr_accessor :place_id

  validates :first_name, :last_name, :title, presence: true
  validates :phone, presence: true, unless: proc { refused_phone? || no_phone? }
  validate :mobile_phone_number, unless: proc { refused_phone? || no_phone? }

  enum title: %i[male female]

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def profile_path
    Rails.application.routes.url_helpers.convict_path(id)
  end

  def booked_appointments
    appointments.where(state: 'booked')
  end

  def passed_appointments
    appointments.joins(:slot)
                .where(state: 'booked')
                .where('slots.date': ..Date.today)
  end

  def mobile_phone_number
    return unless phone && !phone.start_with?('+336', '+337')

    errors.add :phone, I18n.t('activerecord.errors.models.convict.attributes.phone.mobile')
  end
end
