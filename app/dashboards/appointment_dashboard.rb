require 'administrate/base_dashboard'

class AppointmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    convict: Field::BelongsTo,
    history_items: Field::HasMany,
    inviter_user_id: Field::Number,
    notifications: Field::HasMany,
    origin_department: Field::Select.with_options(searchable: false, collection: lambda { |field|
                                                                                   field.resource.class.send(field.attribute.to_s.pluralize).keys
                                                                                 }),
    prosecutor_number: Field::String,
    slot: Field::BelongsTo,
    state: Field::String,
    user: Field::BelongsTo,
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
    state
    slot
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    convict
    history_items
    inviter_user_id
    notifications
    origin_department
    prosecutor_number
    slot
    state
    user
    versions
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    convict
    history_items
    inviter_user_id
    notifications
    origin_department
    prosecutor_number
    slot
    state
    user
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

  # Overwrite this method to customize how appointments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(appointment)
  #   "Appointment ##{appointment.id}"
  # end
end
