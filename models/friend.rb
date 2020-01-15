class Friend < DBEntity

    attr_accessor :id, :username, :last_interaction, :friends_since

    def initialize(user_id, relation_id)
        properties = self.properties(user_id, relation_id)
        @id = properties['id']
        @username = properties['username']
        @last_interaction = properties['last_interaction']
        @friends_since = properties['friends_since']
    end

    def properties(user_id, relation_id)
        self.db.execute("SELECT id, username FROM users WHERE id = ?", user_id).first.merge(self.db.execute("SELECT last_interaction, friends_since FROM friends WHERE id = ?", relation_id).first)
    end

    def self.send_request(user_id, user2_id)
        db.execute("INSERT INTO friends (user_id, user2_id, status, last_interaction, friends_since) VALUES(?,?,?,?,?)", user_id, user2_id, 1, "#{Time.now.utc}", "")
    end

    def self.accept_request(user_id, user2_id)
        db.execute("UPDATE friends SET status = ?, last_interaction = ?, friends_since = ? WHERE id = ?", 0, "#{Time.now.utc}", "#{Time.now.utc}", Friend.relation_id(user_id, user2_id))
    end

    def self.pending_requests(id)
        temp = db.execute("SELECT user_id FROM friends WHERE user2_id = ? AND status = ?", id, 1)
        out = []
        temp.each do |id|
            out << User.new(id['user_id'])
        end
        return out
    end

    def self.sender(user_id, user2_id)
        temp = db.execute("SELECT user_id FROM friends WHERE user_id = ? AND user2_id = ? AND status = ?", user_id, user2_id, 1).first
        if temp != nil
            if temp['user_id'] == user_id
                return user_id
            else
                return user2_id
            end
        end
        temp = db.execute("SELECT user_id FROM friends WHERE user_id = ? AND user2_id = ? AND status = ?", user2_id, user_id, 1).first
        if temp != nil
            if temp['user_id'] == user_id
                return user_id
            else
                return user2_id
            end
        end
        return nil
    end

    def self.status?(user_id, user2_id)
        temp = db.execute("SELECT status FROM friends WHERE user_id = ? AND user2_id = ?", user_id, user2_id).first
        if temp != nil
            if temp['status'] == 0
                return "friends"
            elsif temp['status'] == 1
                return "pending"
            end
        end
        temp = db.execute("SELECT status FROM friends WHERE user_id = ? AND user2_id = ?", user_id, user2_id).first
        if temp != nil
            if temp['status'] == 0
                return "friends"
            elsif temp['status'] == 1
                return "pending"
            end
        end
        return nil
    end

    def self.relation_id(user_id, user2_id)
        temp = db.execute("SELECT id FROM friends WHERE user_id = ? AND user2_id = ?", user_id, user2_id).first
        if temp != nil
            return temp['id']
        end
        temp = db.execute("SELECT id FROM friends WHERE user_id = ? AND user2_id = ?", user2_id, user_id).first
        if temp != nil
            return temp['id']
        end
        return nil
    end

end