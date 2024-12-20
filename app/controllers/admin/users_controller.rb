module Admin
  class UsersController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.

    def index
      authorize_resource(resource_class)
      search_term = params[:search].to_s.strip
      resources = find_resources(search_term)
      page = Administrate::Page::Collection.new(dashboard, order:)

      render locals: {
        resources:,
        search_term:,
        page:,
        show_search_bar: show_search_bar?
      }
    end

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
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def impersonate
      user = User.find(params[:user_id])

      impersonate_user(user)
      redirect_to root_path
    end

    def unlock
      user = User.find(params[:user_id])

      return unless user.present?

      user.unlock_access!
      redirect_to admin_users_path
    end

    def find_resources(search_term)
      search_terms = search_term.split
      roles = (search_terms & User.roles.keys)
      if roles.empty?
        resources = filter_resources(scoped_resource, search_term:)
        resources = apply_collection_includes(resources)
      else
        User.roles.each_key { |r| search_terms.delete(r) }
        resources = filter_resources(scoped_resource, search_term: search_terms.join(' '))
        resources = apply_collection_includes(resources)
        resources = resources.where(role: User.roles[roles.first])
      end

      resources = order.apply(resources)
      paginate_resources(resources)
    end
  end
end
