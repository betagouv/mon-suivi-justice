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

      return unless Rails.env.development?

      Rails.application.load_seed
      @admin = User.find_by email: 'admin@example.com'
      sign_in(@admin)
      redirect_to admin_root_path
    end

    private

    def truncate_db
      if Rails.env.development?
        ActiveRecord::Base.connection.tables.each do |t|
          # We don't want to delete the SRJ tables
          next if %w[schema_migrations monsuivijustice_relation_commune_structure monsuivijustice_commune
                     monsuivijustice_structure].include?(t)

          conn = ActiveRecord::Base.connection
          conn.execute("TRUNCATE TABLE #{t} CASCADE;")
          conn.reset_pk_sequence!(t)
        end
      end

      ActiveRecord::Base.connection.execute("
        TRUNCATE TABLE cities RESTART IDENTITY CASCADE;
        TRUNCATE TABLE srj_tjs RESTART IDENTITY CASCADE;
        TRUNCATE TABLE srj_spips RESTART IDENTITY CASCADE;
      ")

      ActiveRecord::Base.connection.execute("
        INSERT INTO cities(name, zipcode, code_insee, city_id, updated_at, created_at)
        SELECT
          c.names AS name,
          c.postal_code AS zipcode,
          c.insee_code AS code_insee,
          c.id AS city_id,
          NOW() as upadted_at,
          NOW() as created_at
      FROM monsuivijustice_commune c;")

      ActiveRecord::Base.connection.execute("

        INSERT INTO srj_spips(name, structure_id, updated_at, created_at)
          SELECT DISTINCT
            s.name,
            s.id AS structure_id,
            NOW() as updated_at,
            NOW() as created_at
        FROM monsuivijustice_structure s
        INNER JOIN monsuivijustice_relation_commune_structure rcs ON rcs.structure_id = s.id
        WHERE s.name LIKE 'Service%' OR s.name LIKE 'Antenne de%'
        ;")

      ActiveRecord::Base.connection.execute("
          INSERT INTO srj_tjs(name, structure_id, updated_at, created_at)
          SELECT DISTINCT
            s.name,
            s.id AS structure_id,
            NOW() as updated_at,
            NOW() as created_at
        FROM monsuivijustice_structure s
        INNER JOIN monsuivijustice_relation_commune_structure rcs ON rcs.structure_id = s.id
        WHERE s.name LIKE 'Tribunal judiciaire%'
        ;")

      ActiveRecord::Base.connection.execute("
        UPDATE
          cities
        SET
          srj_tj_id = srj_tjs.id
        FROM srj_tjs
          INNER JOIN monsuivijustice_relation_commune_structure rcs ON CAST(srj_tjs.structure_id AS integer) = rcs.structure_id
          INNER JOIN monsuivijustice_commune c ON c.id = rcs.commune_id
        WHERE CAST(cities.city_id AS integer) = c.id;")

      ActiveRecord::Base.connection.execute("
        UPDATE
          cities
        SET
          srj_spip_id = srj_spips.id
        FROM srj_spips
          INNER JOIN monsuivijustice_relation_commune_structure rcs ON CAST(srj_spips.structure_id AS integer) = rcs.structure_id
          INNER JOIN monsuivijustice_commune c ON c.id = rcs.commune_id
        WHERE CAST(cities.city_id AS integer) = c.id;")
    end

    def show_search_bar?
      false
    end
  end
end
