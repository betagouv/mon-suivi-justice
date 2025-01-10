require 'administrate/base_dashboard'

class PlaceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    adress: Field::String,
    agendas: Field::HasMany,
    appointment_types: Field::HasMany,
    contact_email: Field::String,
    discarded_at: Field::DateTime,
    main_contact_method: Field::Select.with_options(searchable: false, collection: lambda { |field|
                                                                                     field.resource.class.send(field.attribute.to_s.pluralize).keys
                                                                                   }),
    name: Field::String,
    organization: Field::BelongsTo,
    phone: Field::String,
    place_appointment_types: Field::HasMany,
    preparation_link: Field::String,
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
    adress
    preparation_link
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    organization
    name
    preparation_link
    adress
    agendas
    appointment_types
    contact_email
    main_contact_method
    phone
    created_at
    updated_at
    discarded_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    organization
    name
    preparation_link
    adress
    contact_email
    main_contact_method
    appointment_types
    phone
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
  COLLECTION_FILTERS = {
    no_link: ->(resources) { resources.where(preparation_link: 'https://mon-suivi-justice.beta.gouv.fr/') }
  }.freeze

  # Overwrite this method to customize how places are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(place)
    place.name.to_s
  end
end
