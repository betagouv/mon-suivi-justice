require 'administrate/base_dashboard'

class SlotDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    agenda: Field::BelongsTo,
    appointment_type: Field::BelongsTo,
    appointments: Field::HasMany,
    available: Field::Boolean,
    capacity: Field::Number,
    date: Field::Date,
    duration: Field::Number,
    full: Field::Boolean,
    slot_type: Field::BelongsTo,
    starting_time: Field::Time,
    used_capacity: Field::Number,
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
    agenda
    appointment_type
    appointments
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    agenda
    appointment_type
    appointments
    available
    capacity
    date
    duration
    full
    slot_type
    starting_time
    used_capacity
    versions
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    agenda
    appointment_type
    appointments
    available
    capacity
    date
    duration
    full
    slot_type
    starting_time
    used_capacity
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

  # Overwrite this method to customize how slots are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(slot)
    "#{slot.date.to_fs(:base_date_format)} à #{slot.localized_time.to_fs(:time)}"
  end
end
