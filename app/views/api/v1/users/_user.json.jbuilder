json.id user&.id
json.first_name user&.first_name
json.last_name user&.last_name
json.phone user&.phone
json.email user&.email
json.organization_name user&.organization_name
json.role I18n.translate("activerecord.attributes.user.user_roles.#{user.role}") if user&.role&.present?
