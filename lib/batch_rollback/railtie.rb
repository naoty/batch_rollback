module BatchRollback
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :batch_rollback do
        task :pre_migrate do
          ActiveRecord::SchemaMigration.create_table
          ENV["BR_CURRENT_VERSION"] = ActiveRecord::SchemaMigration.all_versions.last
        end

        task :post_migrate do
          all_versions = ActiveRecord::SchemaMigration.all_versions
          current_version = ENV.delete("BR_CURRENT_VERSION")
          target_version = all_versions.last
          step = all_versions.index(target_version) - (all_versions.index(current_version) || -1)
          next if step == 0

          MigrationStep.create_table
          MigrationStep.create!(
            current_version: current_version,
            target_version: target_version,
            step: step,
          )
        end

        task :pre_rollback do
          next if ENV.has_key?("STEP")

          MigrationStep.create_table
          current_version = ActiveRecord::SchemaMigration.all_versions.last
          migration_step = MigrationStep.where(target_version: current_version).last
          next if migration_step.nil?

          ENV["STEP"] = migration_step.step.to_s
        end
      end

      if Rake::Task.task_defined?("db:migrate")
        Rake::Task["db:migrate"].enhance(["batch_rollback:pre_migrate"]) do
          Rake::Task["batch_rollback:post_migrate"].invoke
        end
      end

      if Rake::Task.task_defined?("db:rollback")
        Rake::Task["db:rollback"].enhance(["batch_rollback:pre_rollback"])
      end
    end
  end
end
