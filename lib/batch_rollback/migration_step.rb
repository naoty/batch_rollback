module BatchRollback
  class MigrationStep < ActiveRecord::Base
    class << self
      def table_name
        "br_migration_steps"
      end

      def create_table
        return if table_exists?

        connection.create_table(table_name) do |t|
          t.integer :step, null: false
          t.string :target_version, null: false
        end
      end
    end
  end
end
