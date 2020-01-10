class Friend < DBEntity

    attr_accessor :id, :username, :last_interaction, :friends_since

    def initialize(id)
        properties = self.properties(id)
        @id = properties['id']
        @username = properties['username']
        @last_interaction = properties['last_interaction']
        @friends_since = properties['friends_since']
    end

    def properties(id)
        self.db.execute("SELECT id, username FROM users WHERE id = ?", id).first.merge(self.db.execute("SELECT last_interaction, friends_since FROM friends WHERE user_id = ?", id).first)
    end

    def self.add(id, friend_id)
        db.execute("INSERT INTO friends (user_id, friends_id, timestamp) VALUES(?,?,?)", id, friend_id, "#{Time.now}")
    end

end