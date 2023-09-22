module Admin
  class DbResetService
    def self.reset_database
      truncate_tables if Rails.env.development?
      clear_records if Rails.env.development?
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
  end
end
