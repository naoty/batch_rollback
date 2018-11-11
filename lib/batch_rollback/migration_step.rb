module BatchRollback
  class MigrationStep < ActiveRecord::Base
    class << self
      def table_name
        "br_migration_steps"
      end

      def create_table
        return if table_exists?

        connection.create_table(table_name) do |t|
          t.string :current_version
          t.string :target_version
          t.integer :step
        end
      end
    end
  end
end
