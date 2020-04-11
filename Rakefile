task :seed do
    ruby "seeder.rb"
end

task :run do
    sh 'bundle exec rerun --ignore "*.{slim,js,css}" "rackup --host 0.0.0.0"'
end

task :serverrun do
    sh 'gem install sinatra'
    sh 'gem install slim'
    sh 'gem install sqlite3'
    sh 'gem install wdm'
    sh 'gem install rerun'
    sh 'gem install bcrypt'
    sh 'gem install localtunnel'
    sh 'bundle exec rerun --ignore "*.{slim,js,css}" "rackup --host 0.0.0.0"'
end