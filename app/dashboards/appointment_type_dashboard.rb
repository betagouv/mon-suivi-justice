require 'administrate/base_dashboard'

class AppointmentTypeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    notification_types: Field::HasMany,
    place_appointment_types: Field::HasMany,
    places: Field::HasMany,
    share_address_to_convict: Field::Boolean,
    slot_types: Field::HasMany,
    slots: Field::HasMany,
    versions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    notification_types
    place_appointment_types
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    notification_types
    place_appointment_types
    places
    share_address_to_convict
    slot_types
    slots
    versions
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    notification_types
    place_appointment_types
    places
    share_address_to_convict
    slot_types
    slots
    versions
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

  # Overwrite this method to customize how appointment types are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(appointment_type)
    appointment_type.name.to_s
  end
end
