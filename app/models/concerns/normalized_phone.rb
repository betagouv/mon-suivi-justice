# frozen_string_literal: true

module NormalizedPhone
  extend ActiveSupport::Concern

  included do
    # Phone attribute will be normalized to a +33... format BEFORE validation and database hit
    phony_normalize :phone, default_country_code: 'FR'
    validates :phone, phony_plausible: true
  end

  #
  # HUman readable phone number without international prefix, space between 2 digits numbers
  # ie: 05 61 08 37 31
  #
  def display_phone
    phone.phony_formatted format: :national
  end
end
