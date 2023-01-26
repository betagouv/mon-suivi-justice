module Admin
  class ImportConvictsController < Admin::ApplicationController
    include Devise::Controllers::Helpers
    require 'csv'

    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    def import
      @file_extension = File.extname(params[:convicts_list].original_filename)
      raise StandardError, 'Seul le format csv est supporté' unless %w[.csv].include? @file_extension.downcase

      @organization = Organization.find(params[:organization_id])

      temp_csv = params[:convicts_list].tempfile
      csv = CSV.read(temp_csv,
                     { headers: true, col_sep: ';', external_encoding: 'iso-8859-1', internal_encoding: 'utf-8' })

      @import_errors = []
      @import_successes = []

      csv.each do |row|
        # TODO : ajout de la commune quand le SRJ sera intégré à l'application

        next if ['EMPRISONNEMENT', 'AMÉNAGEMENT DE PEINE',
                 'Placement en détention provisoire'].include?(row['Mesure/Intervention'].split(' (')[0])

        convict = Convict.new(
          first_name: row['Prénom'],
          last_name: row['Nom'],
          date_of_birth: row['Date de naissance'].to_date,
          no_phone: true,
          appi_uuid: row['Numéro de dossier'].split('°')[1]
        )

        if convict.save
          RegisterLegalAreas.for_convict convict, from: @organization
          @import_successes.push("#{convict.first_name} #{convict.last_name} (id: #{convict.id})")
        else
          @import_errors.push("#{convict.first_name} #{convict.last_name} - #{convict.errors.full_messages.first}")
        end
      end
    rescue StandardError => e
      flash.now[:error] = "Erreur : #{e.message}"
    else
      flash.now[:success] =
        'Import terminé. Vérifiez les éventuelles erreurs ci-dessous'
    ensure
      render :index
      temp_csv.unlink
    end

    private

    def show_search_bar?
      false
    end
  end
end
