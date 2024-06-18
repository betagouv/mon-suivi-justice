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

    # Add error if appi_uuid doesn't match any valid format
    return true if /(200|201|202)\d{9}([A-Za-z]?)$|^(199|200)\d{5}([A-Za-z]?)/.match?(appi_uuid)

    [false, I18n.t('activerecord.errors.models.convict.attributes.appi_uuid.invalid')]
  end
end
