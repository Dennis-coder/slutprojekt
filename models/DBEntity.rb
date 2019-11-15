class DBEntity

    def self.db
        @db ||= SQLite3::Database.new 'db/websnap.db'
    end

end