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

          if step > 0
            MigrationStep.create_table
            MigrationStep.create!(
              current_version: current_version,
              target_version: target_version,
              step: step,
            )
          end
        end

        task :pre_rollback do
          puts "TODO: pre_rollback"
        end

        task :post_rollback do
          puts "TODO: post_rollback"
        end
      end

      if Rake::Task.task_defined?("db:migrate")
        Rake::Task["db:migrate"].enhance(["batch_rollback:pre_migrate"]) do
          Rake::Task["batch_rollback:post_migrate"].invoke
        end
      end

      if Rake::Task.task_defined?("db:rollback")
        Rake::Task["db:rollback"].enhance(["batch_rollback:pre_rollback"]) do
          Rake::Task["batch_rollback:post_rollback"].invoke
        end
      end
    end
  end
end
