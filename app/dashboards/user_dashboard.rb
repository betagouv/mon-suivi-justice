require 'administrate/base_dashboard'

class UserDashboard < Administrate::BaseDashboard
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
    appointments: Field::HasMany,
    convicts: Field::HasMany,
    email: Field::String,
    password: Field::String.with_options(
      searchable: false
    ),
    password_confirmation: Field::String.with_options(
      searchable: false
    ),
    first_name: Field::String,
    invitation_accepted_at: Field::DateTime,
    invitation_created_at: Field::DateTime,
    invitation_limit: Field::Number,
    invitation_sent_at: Field::DateTime,
    invitation_token: Field::String,
    invitations_count: Field::Number,
    invited_by: Field::Polymorphic,
    last_name: Field::String,
    organization: Field::BelongsTo.with_options(
      searchable: true,
      searchable_fields: ['name']
    ),
    phone: Field::String,
    remember_created_at: Field::DateTime,
    reset_password_sent_at: Field::DateTime,
    reset_password_token: Field::String,
    role: Field::Enum,
    share_email_to_convict: Field::Boolean,
    share_phone_to_convict: Field::Boolean,
    visits: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    security_charter_accepted?: Field::Boolean,
    headquarter: Field::BelongsTo,
    locked_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    organization
    role
    first_name
    last_name
    email
    headquarter
    security_charter_accepted?
    locked_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    first_name
    last_name
    organization
    phone
    remember_created_at
    role
    appointments
    convicts
    share_email_to_convict
    share_phone_to_convict
    visits
    invitation_accepted_at
    invitation_created_at
    invitation_limit
    invitation_sent_at
    invitation_token
    invitations_count
    invited_by
    reset_password_sent_at
    created_at
    updated_at
    security_charter_accepted?
    headquarter
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    email
    first_name
    last_name
    organization
    phone
    role
    share_email_to_convict
    share_phone_to_convict
    headquarter
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

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    "##{user.id} #{user.first_name} #{user.last_name}"
  end
end
