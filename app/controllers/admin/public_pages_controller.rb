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

        # Get develop branch hash (https://docs.github.com/fr/rest/git/refs?apiVersion=2022-11-28#get-a-reference)
        # develop_sha = gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/develop").object.sha

        # Create new branch from develop
        # gh_api_client.create_ref("betagouv/mon-suivi-justice-public", "heads/add-spipXX", develop_sha)

        gh_api_client = Octokit::Client.new(:access_token => ENV['GITHUB_API_TOKEN'])

        spip_name = params[:spip_name]

        # gather info about the image
        uploaded_image = params[:picture].tempfile
        uploaded_image.binmode
        file64 =  Base64.strict_encode64(uploaded_image.read)
        mime_type = "image/png"
        uploaded_image_name = params[:picture].original_filename
        image_path_in_repo = "app/frontend/images/#{uploaded_image_name}"

        sha = gh_api_client.get("/repos/betagouv/mon-suivi-justice-public/git/ref/heads/add-spipXX").object.sha

        begin
          existing_image = gh_api_client.contents("betagouv/mon-suivi-justice-public", {path: image_path_in_repo, ref: sha})
          
        rescue Octokit::NotFound
          gh_api_client.create_contents("betagouv/mon-suivi-justice-public",
            image_path_in_repo,
            "Adding content",
            file64,
            {branch: "add-spipXX"})
        else
          #debugger
          gh_api_client.update_contents("betagouv/mon-suivi-justice-public",
            image_path_in_repo,
            "Updating image",
            existing_image[:sha],
            file64,
            {branch: "add-spipXX"})
        end
      
        reponse = gh_api_client.last_response

        uploaded_image.close
        uploaded_image.unlink 
        

      end
    
      private
  
      def show_search_bar?
        false
      end
    end
  end