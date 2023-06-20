module Admin
  class DbResetService
    def self.reset_database
      truncate_tables if Rails.env.development?
      clear_records
      populate_cities_with_data
      update_city_associations
    end

    def self.truncate_tables
      excluded_tables = %w[schema_migrations monsuivijustice_relation_commune_structure monsuivijustice_commune
                           monsuivijustice_structure]
      ActiveRecord::Base.connection.tables.each do |table|
        next if excluded_tables.include?(table)

        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
      end
    end

    def self.clear_records
      City.destroy_all
      SrjTj.destroy_all
      SrjSpip.destroy_all
      reset_pk_sequence(%w[cities srj_tjs srj_spips])
    end

    def self.reset_pk_sequence(tables)
      tables.each do |table|
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
      end
    end

    def self.populate_cities_with_data
      ActiveRecord::Base.connection.execute("
          INSERT INTO cities(name, zipcode, code_insee, city_id, updated_at, created_at)
          SELECT
            c.names AS name,
            c.postal_code AS zipcode,
            c.insee_code AS code_insee,
            c.id AS city_id,
            NOW() as updated_at,
            NOW() as created_at
          FROM monsuivijustice_commune c;")
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Layout/LineLength
    def self.update_city_associations
      ActiveRecord::Base.connection.execute("
          INSERT INTO srj_spips(name, structure_id, updated_at, created_at)
          SELECT DISTINCT
            ms.name,
            ms.id AS structure_id,
            NOW() as updated_at,
            NOW() as created_at
          FROM public.monsuivijustice_commune mc
          INNER JOIN (
              SELECT rcs.commune_id, MIN(CASE WHEN s.name LIKE '%Antenne%' THEN s.id ELSE NULL END) AS antenne_structure_id, MIN(CASE WHEN s.name NOT LIKE '%Antenne%' THEN s.id ELSE NULL END) AS other_structure_id
              FROM public.monsuivijustice_relation_commune_structure rcs
              INNER JOIN public.monsuivijustice_structure s ON s.id = rcs.structure_id
              WHERE s.name NOT LIKE '%Tribunal%'
              GROUP BY rcs.commune_id
          ) AS structures ON structures.commune_id = mc.id
          LEFT JOIN public.monsuivijustice_structure ms ON ms.id = COALESCE(structures.antenne_structure_id, structures.other_structure_id)
          WHERE mc.id NOT IN (
              SELECT c.id FROM public.monsuivijustice_commune c
              INNER JOIN public.monsuivijustice_relation_commune_structure rcs ON rcs.commune_id = c.id
              INNER JOIN public.monsuivijustice_structure s ON s.id = rcs.structure_id
              WHERE s.name LIKE '%Service%'
              GROUP BY c.id
              HAVING count(*) > 2
          );")

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
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Layout/LineLength
  end
end
