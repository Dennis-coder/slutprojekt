require 'sqlite3'
require_relative 'models/SQLQuery.rb'
require_relative 'models/DBTest.rb'

result = DBTest.connection

task :seed do
    if result == true
        ruby "seeder.rb"
    else
        puts "Connection issues with the database"
    end
end

task :run do
    if result == true
        sh 'bundle exec rerun --ignore "*.{slim,js,css}" "rackup --host 0.0.0.0"'
    else
        puts "Connection issues with the database"
    end
end

task :acceptance do
    Rake::Task["seed"].invoke #reset db before each test file is run
    system("bundle exec 'ruby ./spec/acceptance/tests.rb'")        
end