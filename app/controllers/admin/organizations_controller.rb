module Admin
  class OrganizationsController < Admin::ApplicationController
    def link_convict_from_linked_orga
      organization = Organization.find(params[:organization_id])
      linked_organizations = organization.linked_organizations
      linked = []
      linked_organizations.each do |linked_organization|
        linked_organization.convicts.each do |convict|
          next if convict.organizations.include?(organization)

          convict.organizations.push(organization)
          convict.save
          linked << convict
        end
      end
      redirect_back(fallback_location: root_path)
    end
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   linked_orga_id = params[:organization][:linked_organization]
    #   params[:organization][:linked_organization] = Organization.find(linked_orga_id) unless linked_orga_id.blank?
    #   super
    # end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #   if current_user.super_admin?
    #     resource_class
    #   else
    #     resource_class.with_less_stuff
    #   end
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
