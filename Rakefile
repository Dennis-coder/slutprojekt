require_relative 'models/db_test.rb'
result = DBTest.start

task :seed do
    if result == true
        ruby "seeder.rb"
    else
        puts "Connection issues with the database"
    end
end

task :run do
    # if result == true
        sh 'bundle exec rerun --ignore "*.{slim,js,css}" "rackup --host 0.0.0.0"'
    # else
        # puts "Connection issues with the database"
    # end
end

#rake run
#rake debug
#rake seed
#rake test:unit
#rake test:acceptance

#http://127.0.0.1:9292/
