class Friend < DBEntity

    attr_accessor :id, :username, :last_interaction, :messages

    def initialize()
        @id = nil
        @username = nil
        @last_interaction = nil
        @messages = nil
    end

    def properties(user_id, friend_id)
        self.db.execute("SELECT id, username FROM users WHERE id = ?", friend_id).first.merge(self.db.execute("SELECT last_interaction FROM friends WHERE (user_id = ? AND user2_id = ?) OR (user2_id = ? AND user_id = ?)", user_id, friend_id, user_id, friend_id).first)
    end

    def get_messages(user_id)
        hash_list = db.execute("SELECT id FROM messages WHERE (reciever_id = ? AND sender_id = ?) OR (reciever_id = ? AND sender_id = ?) ORDER BY timestamp", user_id, @id, @id, user_id)
        list = []
        hash_list.each do |hash|
            list << Message.get(hash['id'], 'friend')
        end
        return list
    end

    def self.get(user_id, friend_id)
        friend = Friend.new()
        properties = friend.properties(user_id, friend_id)
        friend.id = properties['id']
        friend.username = properties['username']
        friend.last_interaction = properties['last_interaction']
        friend.messages = friend.get_messages(user_id)

        return friend
    end

    def self.send_request(user_id, user2_id)
        db.execute("INSERT INTO friends (user_id, user2_id, status, last_interaction) VALUES(?,?,?,?)", user_id, user2_id, 1, "#{Time.now}")
    end

    def self.accept_request(user_id, user2_id)
        db.execute("UPDATE friends SET status = ?, last_interaction = ? WHERE id = ?", 0, "#{Time.now}", Friend.relation_id(user_id, user2_id))
    end

    def self.pending_requests(id)
        temp = db.execute("SELECT user_id FROM friends WHERE user2_id = ? AND status = ?", id, 1)
        out = []
        temp.each do |id|
            out << User.get(id['user_id'])
        end
        return out
    end

    def self.sender(user_id, user2_id)
        temp = db.execute("SELECT user_id FROM friends WHERE ((user_id = ? AND user2_id = ?) OR (user_id = ? AND user2_id = ?)) AND status = ?", user_id, user2_id, user2_id, user_id, 1).first
        if temp != nil
            if temp['user_id'] == user_id
                return user_id
            else
                return user2_id
            end
        end
        return nil
    end

    def self.delete(user_id, user2_id)
        db.execute("DELETE FROM friends WHERE id = ?", Friend.relation_id(user_id, user2_id))
    end

    def self.status?(user_id, user2_id)
        temp = db.execute("SELECT status FROM friends WHERE (user_id = ? AND user2_id = ?) OR (user_id = ? AND user2_id = ?)", user_id, user2_id, user2_id, user_id).first
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
        temp = db.execute("SELECT id FROM friends WHERE (user_id = ? AND user2_id = ?) OR (user_id = ? AND user2_id = ?)", user_id, user2_id, user2_id, user_id).first
        if temp != nil
            return temp['id']
        end
        return nil
    end

    def self.new_messages(user_id, params)
        friend = Friend.get(user_id, params['id'].to_i)
        latest = params['latest']
        newMessages = []
        friend.messages.each do |message|
            if !Sorter.timestamp_compare(latest, message.timestamp) && message.sender_id != user_id
                newMessages << {'text' => message.text, 'timestamp' => message.timestamp, 'sender' => User.username(message.sender_id)}
            end
        end
        return newMessages
    end

end