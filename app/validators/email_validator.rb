require 'uri'

class EmailValidator < ActiveModel::Validator
  def validate(record)
    return if record.email.match? URI::MailTo::EMAIL_REGEXP

    record.errors[:email] << 'has an invalid format'
    raise ActiveRecord::Rollback
  end
end
