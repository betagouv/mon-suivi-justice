json.id user&.id
json.first_name user&.first_name
json.last_name user&.last_name
json.phone user&.phone
json.email user&.email
json.organization_name user&.organization_name
json.share_phone_to_convict user&.share_phone_to_convict
json.share_email_to_convict user&.share_email_to_convict
json.role I18n.translate("activerecord.attributes.user.user_roles.#{user.role}") if user&.role&.present?
