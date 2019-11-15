class Friend < DBEntity

    def self.friends_by_user(id)
        db.execute("SELECT friends_id FROM friends WHERE user_id = ?", id)
    end

end