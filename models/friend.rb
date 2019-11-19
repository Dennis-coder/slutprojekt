class Friend < DBEntity

    def self.friendslist(id)
        db.execute("SELECT friends_id FROM friends WHERE user_id = ?", id)
    end

    def self.last_interaction(user_id, friend_id)
        db.execute("SELECT last_interaction FROM friends WHERE user_id = ? AND friends_id = ?", user_id, friend_id)
    end 

    def self.add(id, friend_id)
        db.execute("INSERT INTO friends (user_id, friends_id, timestamp) VALUES(?,?,?)", id, friend_id, "#{Time.now}")
    end

end