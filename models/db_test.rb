require 'sqlite3'

class DBTest

    def self.start
        begin 

            @db = SQLite3::Database.new 'db/awebsnap.db'
            @db.results_as_hash = true

            @db.execute("SELECT * FROM users")

        rescue 

            return false

        end

        return true
    end

end