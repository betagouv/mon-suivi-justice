module Admin
  class OrganizationDivestmentsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    def update
      success = process_state(resource_params[:state], requested_resource, current_user)

      if success
        redirect_to(
          after_resource_updated_path(requested_resource),
          notice: translate_with_resource('update.success'),
          status: :see_other
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }, status: :unprocessable_entity
      end
    end

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
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes(action_name)).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information

    def process_state(state, resource, user)
      state_service = DivestmentStateService.new(resource, user)
      comment = 'Ce dessaisissement a été effectué par un administrateur.'
      case state
      when 'accepted'
        state_service.accept(comment)
      when 'refused'
        state_service.refuse(comment)
      else
        false
      end
    end
  end
end
