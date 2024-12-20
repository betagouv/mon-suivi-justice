module Admin
  class ConvictsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    def update
      requested_resource.current_user = current_user

      if requested_resource.update(resource_params)
        requested_resource.toggle_japat_orgs
        redirect_to(
          after_resource_updated_path(requested_resource),
          notice: translate_with_resource('update.success')
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }, status: :unprocessable_entity
      end
    end

    def merge_form
      # Affiche le formnulaire de selection pour la fusion
    end

    def merge_preview
      @kept_convict = Convict.find(params[:kept_id])
      @duplicated_convict = Convict.find(params[:duplicated_id])

      @duplicated_appointments_count = @duplicated_convict.appointments.count
      @duplicated_history_items_count = @duplicated_convict.history_items.count
    rescue ActiveRecord::RecordNotFound => e
      redirect_to merge_form_admin_convicts_path, alert: "Le probationnaire d'id #{e.id} n'existe pas"
      nil
    end

    def merge_execute
      kept_id = params[:kept_id]
      duplicated_id = params[:duplicated_id]

      # Appel de votre service de fusion
      Convicts::MergeService.call(kept_id: kept_id, duplicated_id: duplicated_id)

      redirect_to admin_convict_path(kept_id), notice: 'Les probationnaires ont été fusionnés avec succès.'
    rescue StandardError
      kept_id = params[:kept_id]
      duplicated_id = params[:duplicated_id]
      redirect_to merge_preview_admin_convicts_path(kept_id: kept_id, duplicated_id: duplicated_id),
                  alert: "Une erreur s'est produite lors de la fusion"
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
