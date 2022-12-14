module Admin
    class PublicPagesController < Admin::ApplicationController
      include Devise::Controllers::Helpers
      require 'octokit'
      require 'base64'
  
      def index
        render locals: {
          resources: [],
          search_term: '',
          page: '',
          show_search_bar: show_search_bar?,
        }
      end

      def create
        @org_name = params[:organization_name]
        @gh_api_client = Octokit::Client.new(:access_token => ENV['GITHUB_API_TOKEN'])

        develop_sha = @gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/develop").object.sha

        @gh_api_client.create_ref("betagouv/mon-suivi-justice-public", "heads/add-#{@org_name}-page", develop_sha)

        @new_page_branch = @gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/add-#{@org_name}-page").object.sha

        # Build required spina files and commit them to the newly created branch
        handle_image
        handle_template
        handle_routes
        handle_pages_controller
        handle_spina_conf_file
        handle_spec_file
        create_pull_request

        flash[:notice] = "Le code de la page a été correctement généré. Demandez à un développeur de la déployer en production"

        # IDEE : pinger l'équipe de dév (Mattermost, mail,...) ?

        redirect_to admin_public_pages_path
      end
    
      private

      def handle_image
        image_extension = File.extname(params[:picture].original_filename)
        @image_filename = @org_name + image_extension

        image_repo_path = "app/frontend/images/#{@image_filename}"

        temp_image = params[:picture].tempfile
        # read ensures files is closed before returning
        org_image = temp_image.read
          
        @gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
          image_repo_path,
          "[skip actions] Adding image for #{@org_name}",
          org_image,
          {branch: "add-#{@org_name}-page"})
      
        # ensures file is removed from disk
        temp_image.unlink
      end

      def handle_template
        template_content = File.open("./app/views/admin/public_pages/templates/preparer_page_template.html.erb").read

        Tempfile.create('spina_view.html.erb') do |f|
          new_content = template_content.gsub(/\bplaceholder.jpg\b/, @image_filename)
          f.write(new_content)
          f.rewind

          @gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
            "app/views/pages/preparer_#{@org_name}.html.erb",
            "[skip actions] Adding spina view page for for #{@org_name}",
            f.read,
            {branch: "add-#{@org_name}-page"})
        end
      end

      def handle_routes
        routes_file = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: "config/routes.rb", ref: @new_page_branch})
        @routes_file_rows = Base64.decode64(routes_file[:content]).split("\n")
        insertion_index = @routes_file_rows.index "  scope controller: :pages do"
        @routes_file_rows.insert(insertion_index + 1, "    get :preparer_#{@org_name}")

        Tempfile.create("routes_temp.rb") do |f|
          f.write(@routes_file_rows.join("\n"), "\n")
          f.rewind

          @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            "config/routes.rb",
            "[skip actions] Updating routing file for #{@org_name}",
            routes_file[:sha],
            f.read,
            {branch: "add-#{@org_name}-page"})
        end
      end

      def handle_pages_controller
        pages_controller_file = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: "app/controllers/pages_controller.rb", ref: @new_page_branch})
        @pages_controller_rows = Base64.decode64(pages_controller_file[:content]).split("\n")
        insertion_index = @pages_controller_rows.index "  include Spina::Api::Paginable"
        @pages_controller_rows.insert(insertion_index + 1, "  def preparer_#{@org_name}", "  end")

        Tempfile.create("pages_controller_temp.rb") do |f|
          f.write(@pages_controller_rows.join("\n"), "\n")
          f.rewind

          @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            "app/controllers/pages_controller.rb",
            "[skip actions] Updating pages controller file for #{@org_name}",
            pages_controller_file[:sha],
            f.read,
            {branch: "add-#{@org_name}-page"})

        end
      end

      def handle_spina_conf_file
        spina_conf_file = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: "config/initializers/themes/default.rb", ref: @new_page_branch})
        @spina_conf_file_rows = Base64.decode64(spina_conf_file[:content]).split("\n")

        view_template_insertion_index = @spina_conf_file_rows.index "  theme.view_templates = ["
        @spina_conf_file_rows.insert(view_template_insertion_index + 1, "    {name: \'preparer_#{@org_name}\', title: \'Preparer #{@org_name}\', parts: %w[main_title main_description zip_code_select direction_collapse_title direction_collapse_first_rich_content direction_collapse_second_rich_content direction_collapse_button_text direction_collapse_button_link rich_collapse]},")

        custom_page_insertion_index = @spina_conf_file_rows.index "  theme.custom_pages = ["
        @spina_conf_file_rows.insert(custom_page_insertion_index + 1, "    {name: \'preparer_#{@org_name}\', title: \'Preparer #{@org_name}\', view_template: \'preparer_#{@org_name}\'},")

        Tempfile.create("spina_conf_file_temp.rb") do |f|
          f.write(@spina_conf_file_rows.join("\n").force_encoding('utf-8'), "\n")
          f.rewind

          @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            "config/initializers/themes/default.rb",
            "[skip actions] Updating spina conf file for #{@org_name}",
            spina_conf_file[:sha],
            f.read,
            {branch: "add-#{@org_name}-page"})
        end
      end

      def handle_spec_file
        spec_file = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: "spec/requests/pages_spec.rb", ref: @new_page_branch})
        @spec_file_rows = Base64.decode64(spec_file[:content]).split("\n")
        insertion_index = @spec_file_rows.index "    FactoryBot.create(:account)"
        @spec_file_rows.insert(insertion_index + 3, "  describe 'GET /preparer_#{@org_name}' do", "    let(:path) { preparer_#{@org_name}_path }", "    ", "    it do", "      get path", "      is_expected.to be_successful", "    end", "  end")

        Tempfile.create("spec_file_temp.rb") do |f|
          f.write(@spec_file_rows.join("\n"), "\n")
          f.rewind

          @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            "spec/requests/pages_spec.rb",
            "Updating pages spec file for #{@org_name}",
            spec_file[:sha],
            f.read,
            {branch: "add-#{@org_name}-page"})
        end
      end

      def create_pull_request
        @gh_api_client.create_pull_request("betagouv/mon-suivi-justice-public", "develop", "add-#{@org_name}-page",
          "Creation page #{@org_name}", "Création de la page préparer mon rendez-vous pour le service #{@org_name}")
      end

      def show_search_bar?
        false
      end
    end
  end