module Admin
  class PlaceTransfertsController < Admin::ApplicationController
    def create
      resource = PlaceTransfert.new(resource_params)
      authorize_resource(resource)

      if resource.save
        PreparePlaceTransfertJob.set(wait: 1.hour).perform_later(resource.id, current_user)
        redirect_to(
          after_resource_created_path(resource),
          notice: translate_with_resource('create.success')
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }, status: :unprocessable_entity
      end
    end
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
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
    def resource_params
      new_params = params.require(resource_class.model_name.param_key)
                         .permit(dashboard.permitted_attributes)
                         .transform_values { |value| value == '' ? nil : value }

      old_place = Place.find(new_params[:old_place_id])
      new_place_attributes = new_params[:new_place_attributes].merge(organization_id: old_place.organization_id)
      new_params
        .merge(new_place_attributes:)
    end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
