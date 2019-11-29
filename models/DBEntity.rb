class DBEntity

    def self.db
        @db ||= SQLite3::Database.new 'db/websnap.db'
		# @db.results_as_hash = true
    end

end