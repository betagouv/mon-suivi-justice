class AppiUuidValidator < ActiveModel::Validator
  def validate(record)
    is_valid, error_message = appi_format(record.appi_uuid)
    return if is_valid

    record.errors.add(:appi_uuid, error_message)
  end

  private

  def appi_format(appi_uuid)
    # Return early if appi_uuid is blank
    return true unless appi_uuid.present?

    # Check if appi_uuid consists only of digits
    unless appi_uuid.match?(/\A\d+\z/)
      return false, I18n.t('activerecord.errors.models.convict.attributes.appi_uuid.only_digits')
    end

    # Define valid formats as combinations of prefix and length
    valid_formats = [
      { prefix: %w[199 200], length: 8 },
      { prefix: %w[200 201 202], length: 12 }
    ]

    # Check if appi_uuid matches any of the valid formats
    is_valid = valid_formats.any? do |format|
      format[:prefix].any? { |prefix| appi_uuid.start_with?(prefix) } && appi_uuid.length == format[:length]
    end

    # Add error if appi_uuid doesn't match any valid format
    return true if is_valid

    [false, I18n.t('activerecord.errors.models.convict.attributes.appi_uuid.invalid')]
  end
end
