require 'administrate/base_dashboard'

class ConvictDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number.with_options(
      searchable: true
    ),
    first_name: Field::String,
    last_name: Field::String,
    full_name: Field::String,
    organizations: Field::HasMany,
    appi_uuid: Field::String,
    city: Field::BelongsToSearch,
    appointments: Field::HasMany,
    no_phone: Field::Boolean,
    homeless: Field::Boolean,
    lives_abroad: Field::Boolean,
    phone: Field::String,
    prosecutor_number: Field::String,
    refused_phone: Field::Boolean,
    timestamp_convict_interface_creation: Field::DateTime,
    user: Field::BelongsTo,
    invitation_to_convict_interface_count: Field::Number,
    last_invite_to_convict_interface: Field::DateTime,
    discarded_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    date_of_birth: Field::Date,
    creating_organization: Field::BelongsTo,
    japat: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    appi_uuid
    first_name
    last_name
    organizations
    phone
    appointments
    date_of_birth
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    appi_uuid
    creating_organization
    organizations
    city
    first_name
    last_name
    phone
    refused_phone
    no_phone
    homeless
    lives_abroad
    prosecutor_number
    user
    japat
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    appi_uuid
    organizations
    city
    first_name
    last_name
    date_of_birth
    phone
    refused_phone
    no_phone
    homeless
    lives_abroad
    prosecutor_number
    user
    japat
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how convicts are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(convict)
    convict.full_name
  end
end
