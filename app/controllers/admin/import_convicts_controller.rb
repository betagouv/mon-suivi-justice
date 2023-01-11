module Admin
  class ImportConvictsController < Admin::ApplicationController
    include Devise::Controllers::Helpers
    require 'octokit'
    require 'base64'

    MSJ_PUBLIC_REPO_PATH = 'betagouv/mon-suivi-justice-public'.freeze

    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    def create

    end

    private

    def show_search_bar?
      false
    end
  end
end
