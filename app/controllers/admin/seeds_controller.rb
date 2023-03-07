module Admin
  class SeedsController < Admin::ApplicationController
    include Devise::Controllers::Helpers

    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    def reset_db
      sign_out(true_user)
      sign_out(current_user)

      truncate_db

      Rails.application.load_seed
      @admin = User.find_by email: 'admin@example.com'
      sign_in(@admin)
      redirect_to admin_root_path
    end

    private

    def truncate_db
      ActiveRecord::Base.connection.tables.each do |t|
        # We don't want to delete the SRJ tables
        next if %w[schema_migrations cities tjs spips commune structure type_structure
                   ln_commune_structure].include?(t)

        conn = ActiveRecord::Base.connection
        conn.execute("TRUNCATE TABLE #{t} CASCADE;")
        conn.reset_pk_sequence!(t)
      end

      ActiveRecord::Base.connection.execute("
        DELETE FROM tjs WHERE 1=1;

        INSERT INTO tjs(name, structure_id, updated_at, created_at)
          SELECT
            s.libelle_principal AS name,
            s.id AS structure_id,
            NOW() as updated_at,
            NOW() as created_at
        FROM structure s
        INNER JOIN type_structure ts on ts.id = s.type_structure_id
        WHERE ts.id = '001000002';")

      ActiveRecord::Base.connection.execute("
        INSERT INTO cities(name, zipcode, code_insee, city_id, updated_at, created_at)
          SELECT
            c.libelle AS name,
            c.code_postal AS zipcode,
            c.code_insee,
            c.id AS city_id,
            NOW() as upadted_at,
            NOW() as created_at
        FROM commune c;")

      ActiveRecord::Base.connection.execute("
        UPDATE cities
          SET
            tj_id = tjs.id
          FROM tjs
            INNER JOIN ln_commune_structure lns ON tjs.structure_id = lns.structure_id
            INNER JOIN commune c ON c.id = lns.commune_id
          WHERE cities.city_id = c.id;")
    end

    def show_search_bar?
      false
    end
  end
end
