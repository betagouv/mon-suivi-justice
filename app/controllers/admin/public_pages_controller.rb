module Admin
    class PublicPagesController < Admin::ApplicationController
      include Devise::Controllers::Helpers
      require 'octokit'
  
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

        # Get develop branch hash (https://docs.github.com/fr/rest/git/refs?apiVersion=2022-11-28#get-a-reference)
        develop_sha = @gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/develop").object.sha

        # Create new branch from develop
        @gh_api_client.create_ref("betagouv/mon-suivi-justice-public", "heads/add-#{@org_name}-page", develop_sha)

        @new_page_branch = @gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/add-#{@org_name}-page").object.sha

        handle_image
        handle_template
        #handle_routes

        flash[:notice] = "La création de la page de RDV est en cours. Elle sera disponible dans le CMS d'ici quelques minutes"

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

        begin
          existing_image = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: image_repo_path, ref: @new_page_branch})
          
        rescue Octokit::NotFound
          @gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
            image_repo_path,
            "Adding image for #{@org_name}",
            org_image,
            {branch: "add-#{@org_name}-page"})
        else
          @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            image_repo_path,
            "Updating image for #{@org_name}",
            existing_image[:sha],
            org_image,
            {branch: "add-#{@org_name}-page"})
        end
      
        reponse = @gh_api_client.last_response

        # ensures file is removed from disk
        temp_image.unlink
      end

      def handle_template
        template_content = File.open("./app/views/admin/public_pages/templates/preparer_page_template.html.erb").read

        Tempfile.create('spina_view') do |f|
          new_content = template_content.gsub(/\bplaceholder.jpg\b/, @image_filename)
          f.write(new_content)
          f.rewind

          view_path_in_repo = "app/views/pages/preparer_test.html.erb"

          begin
            existing_view = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: view_path_in_repo, ref: @new_page_branch})
            
          rescue Octokit::NotFound
            @gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
              view_path_in_repo,
              "Adding spina view page for for #{@org_name}",
              f.read,
              {branch: "add-#{@org_name}-page"})
          else
            # TODO: maybe do nothing here and instead tell the user that the organization already exists ?
            @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
              view_path_in_repo,
              "Updating spina view page for for #{@org_name}",
              existing_view[:sha],
              f.read,
              {branch: "add-#{@org_name}-page"})
          end
          f.close
       end










      end


      def show_search_bar?
        false
      end
    end
  end