module Admin
    class PublicPagesController < Admin::ApplicationController
      include Devise::Controllers::Helpers

      require 'octokit'
      require 'base64'
  
      def index

        gh_api_client = Octokit::Client.new(:access_token => ENV['GITHUB_API_TOKEN'])


        @sha_object = gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/add-spipXX").object



        render locals: {
          resources: [],
          search_term: '',
          page: '',
          show_search_bar: show_search_bar?,
        }
      end

      def create

        # FIND_DEVELOP
        # Get develop branch hash (https://docs.github.com/fr/rest/git/refs?apiVersion=2022-11-28#get-a-reference)
        # develop_sha = gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/develop").object.sha

        # Create new branch from develop
        # gh_api_client.create_ref("betagouv/mon-suivi-justice-public", "heads/add-spipXX", develop_sha)

        @gh_api_client = Octokit::Client.new(:access_token => ENV['GITHUB_API_TOKEN'])
        @org_name = params[:spip_name]
        @sha = @gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/add-spipXX").object.sha

        #handle_image
        handle_template



        flash[:notice] = "La création de la page de RDV est en cours. Elle sera disponible dans le CMS d'ici quelques minutes"

        redirect_to admin_public_pages_path
      end
    
      private

      def handle_image
        image_name = params[:picture].original_filename
        image_path_in_repo = "app/frontend/images/#{image_name}"
        
        temp_picture = params[:picture].tempfile
        # read ensures files is closed before returning
        stringified_picture = temp_picture.read

        begin
          existing_image = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: image_path_in_repo, ref: @sha})
          
        rescue Octokit::NotFound
          @gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
            image_path_in_repo,
            "Adding content",
            stringified_picture,
            {branch: "add-spipXX"})
        else
          @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            image_path_in_repo,
            "Updating image",
            existing_image[:sha],
            stringified_picture,
            {branch: "add-spipXX"})
        end
      
        reponse = @gh_api_client.last_response
        temp_picture.unlink
      end

      def handle_template

        # spina_view_erb = Tempfile.new('spip-test.html.erb')

        template_content = File.open("./app/views/admin/public_pages/templates/preparer_page_template.html.erb").read

        Tempfile.create('spina_view') do |f|

          new_content = template_content.gsub(/\bplaceholder.jpg\b/, "pouet-pouet-mon-image.jpg")

          f.write(new_content)
          f.rewind

          @toto = f.read


          view_path_in_repo = "app/views/pages/preparer_test.html.erb"

          begin
            existing_view = @gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: view_path_in_repo, ref: @sha})
            
          rescue Octokit::NotFound
            @gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
              view_path_in_repo,
              "Adding spina view page for organization",
              @toto,
              {branch: "add-spipXX"})
          else
            @gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
              view_path_in_repo,
              "Updating spina view page for organization",
              existing_view[:sha],
              @toto,
              {branch: "add-spipXX"})
          end




          #debugger
          f.close
       end










      end


      def show_search_bar?
        false
      end
    end
  end