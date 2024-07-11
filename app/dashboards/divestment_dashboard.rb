require 'administrate/base_dashboard'

class DivestmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    decision_date: Field::Date,
    organization: Field::BelongsTo.with_options(
      searchable: true,
      searchable_fields: ['name']
    ),
    state: Field::String,
    user: Field::BelongsTo,
    convict: Field::BelongsTo.with_options(
      searchable: true,
      searchable_fields: %w[first_name last_name]
    ),
    created_at: Field::Date,
    updated_at: Field::DateTime,
    organization_divestments: Field::HasMany
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    convict
    user
    created_at
    decision_date
    organization
    state
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    decision_date
    organization
    organization_divestments
    user
    convict
    state
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    decision_date
    state
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
    repondre: lambda(&:admin_action_needed)
  }.freeze

  # Overwrite this method to customize how divestments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(divestment)
  #   "Divestment ##{divestment.id}"
  # end
end
