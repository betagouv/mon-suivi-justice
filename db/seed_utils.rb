require "faker"

def create_user(organization:, role:, email: Faker::Internet.email, headquarter: nil)
  User.find_or_create_by!(
    organization: organization,
    email: email,
    role: role,
    headquarter: headquarter
  ) do |user|
    user.password = ENV["DUMMY_PASSWORD"]
    user.password_confirmation = ENV["DUMMY_PASSWORD"]
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
  end
end

def create_convict(organizations:, city: nil)
  Faker::Config.locale = 'fr'
  Convict.create!(city: city, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989)) do |convict|
    convict.first_name = Faker::Name.first_name
    convict.last_name = Faker::Name.last_name
    convict.no_phone = true # we don't want to send SMS to convicts during tests
    convict.organizations = organizations.is_a?(Array) ? organizations : [organizations]
  end
end

def create_spip(name:, tjs: [], headquarter: nil)
  Organization.find_or_create_by!(name: name, organization_type: :spip, headquarter: headquarter) do |org|
    org.tjs = tjs.is_a?(Array) ? tjs : [tjs]
  end
end

def create_tj(name:, use_inter_ressort: false)
  Organization.find_or_create_by!(name: name, organization_type: :tj, use_inter_ressort: use_inter_ressort)
end