module BatchRollback
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :batch_rollback do
        task :pre_migrate do
          puts "TODO: pre_migrate"
        end

        task :post_migrate do
          puts "TODO: post_migrate"
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
