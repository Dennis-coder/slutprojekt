class DBEntity

    def db
        return @db if @db
        @db = SQLite3::Database.new 'db/websnap.db'
        @db.results_as_hash = true
        return @db
    end

end