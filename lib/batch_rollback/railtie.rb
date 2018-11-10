module BatchRollback
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :db do
        task :migrate do
          MigrationStep.create_table
        end

        task :rollback do
          puts "TODO: hook db:rollback"
        end
      end
    end
  end
end
