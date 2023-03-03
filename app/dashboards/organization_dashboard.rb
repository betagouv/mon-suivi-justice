require 'administrate/base_dashboard'

class OrganizationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    areas_organizations_mappings: Field::HasMany,
    departments: Field::HasMany,
    jurisdictions: Field::HasMany,
    name: Field::String,
    notification_types: Field::HasMany,
    organization_type: Field::Select.with_options(searchable: false, collection: lambda { |field|
                                                                                   field.resource.class.send(field.attribute.to_s.pluralize).keys
                                                                                 }),
    places: Field::HasMany,
    rich_text_jap_modal_content: Field::HasOne,
    time_zone: Field::String,
    users: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    linked_or_associated_organization_display_name: Field::String,
    linked_organization_id: Field::Select.with_options(searchable: true, include_blank: true, collection: lambda { |field|
                                                                                                            associated_organization = Organization.includes(:associated_organization).find { |orga| orga.linked_organization_id == field.resource.id }

                                                                                                            # when the organization has an associated organization, we only want to display it in the select
                                                                                                            if associated_organization.present?
                                                                                                              return [[associated_organization.name, associated_organization.id]]
                                                                                                            end

                                                                                                            # otherwise, we want to display all organizations that are not the same type as the current organization and that don't have an associated organization
                                                                                                            Organization.includes(:associated_organization).reject { |o| o.organization_type == field.resource.organization_type || (o.linked_or_associated_organization.present? && o.linked_or_associated_organization.id != field.resource.id) }.map { |o| [o.name, o.id] }
                                                                                                          })
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    organization_type
    departments
    jurisdictions
    linked_or_associated_organization_display_name
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    organization_type
    name
    users
    departments
    jurisdictions
    places
    areas_organizations_mappings
    notification_types
    time_zone
    created_at
    updated_at
    linked_or_associated_organization_display_name
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    areas_organizations_mappings
    departments
    jurisdictions
    name
    notification_types
    organization_type
    places
    time_zone
    users
    linked_organization_id
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

  # Overwrite this method to customize how organizations are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(organization)
    "##{organization.id} - #{organization.name}"
  end
end
