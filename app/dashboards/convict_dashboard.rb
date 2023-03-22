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
    appi_uuid: Field::String,
    appointments: Field::HasMany,
    areas_convicts_mappings: Field::HasMany,
    departments: Field::HasMany,
    discarded_at: Field::DateTime,
    first_name: Field::String,
    history_items: Field::HasMany,
    invitation_to_convict_interface_count: Field::Number,
    jurisdictions: Field::HasMany,
    last_invite_to_convict_interface: Field::DateTime,
    last_name: Field::String,
    no_phone: Field::Boolean,
    phone: Field::String,
    prosecutor_number: Field::String,
    refused_phone: Field::Boolean,
    timestamp_convict_interface_creation: Field::DateTime,
    user: Field::BelongsTo,
    versions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    date_of_birth: Field::Date
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
    phone
    appointments
    departments
    jurisdictions
    date_of_birth
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    appi_uuid
    first_name
    last_name
    phone
    refused_phone
    appointments
    departments
    history_items
    jurisdictions
    no_phone
    prosecutor_number
    user
    timestamp_convict_interface_creation
    invitation_to_convict_interface_count
    last_invite_to_convict_interface
    versions
    discarded_at
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    appi_uuid
    first_name
    last_name
    phone
    no_phone
    user
    departments
    jurisdictions
    invitation_to_convict_interface_count
    last_invite_to_convict_interface
    prosecutor_number
    refused_phone
    timestamp_convict_interface_creation
    discarded_at
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
  # def display_resource(convict)
  #   "Convict ##{convict.id}"
  # end
end
