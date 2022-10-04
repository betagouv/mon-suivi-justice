require 'administrate/base_dashboard'

class SlotTypeDashboard < Administrate::BaseDashboard
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
    capacity: Field::Number,
    discarded_at: Field::DateTime,
    duration: Field::Number,
    slots: Field::HasMany,
    starting_time: Field::Time,
    versions: Field::HasMany,
    week_day: Field::Select.with_options(searchable: false, collection: lambda { |field|
                                                                          field.resource.class.send(field.attribute.to_s.pluralize).keys
                                                                        }),
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
    capacity
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    agenda
    appointment_type
    capacity
    discarded_at
    duration
    slots
    starting_time
    versions
    week_day
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    agenda
    appointment_type
    capacity
    discarded_at
    duration
    slots
    starting_time
    versions
    week_day
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

  # Overwrite this method to customize how slot types are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(slot_type)
  #   "SlotType ##{slot_type.id}"
  # end
end
