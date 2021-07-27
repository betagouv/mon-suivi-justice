class Place < ApplicationRecord
  has_paper_trail

  validates :name, :adress, :place_type, :phone, presence: true

  validates :phone, format: { with: Phone::REGEX,
                              message: I18n.t('activerecord.errors.phone_format') }, allow_blank: true

  enum place_type: %i[spip sap]

  has_many :agendas, dependent: :destroy
  accepts_nested_attributes_for :agendas, reject_if: :all_blank, allow_destroy: true
end
